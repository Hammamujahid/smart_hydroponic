#define ENABLE_USER_AUTH
#define ENABLE_DATABASE

#include <Arduino.h>
#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <FirebaseClient.h>

/* ================= WIFI & FIREBASE ================= */
#define WIFI_SSID "WASI FAMILY"
#define WIFI_PASSWORD "01021969"
// #define WIFI_SSID       "Galaxy A03 Core1659"
// #define WIFI_PASSWORD   "hehehehe"
#define Web_API_KEY "AIzaSyCIhqKK-UMKd_Jmw4WGEWojye8P_zNBOro"
#define DATABASE_URL "https://smart-hydroponic-14bcf-default-rtdb.asia-southeast1.firebasedatabase.app"
#define USER_EMAIL "zerxonin@gmail.com"
#define USER_PASS "123456"

/* ================= PIN DEFINITION ================= */
#define RELAY_PH 25
#define RELAY_NUTRIENT 26
#define RELAY_WATER 27
#define TRIG_PIN 19
#define ECHO_PIN 18
#define TDS_PIN 35
#define PH_PIN 34

/* ================= SENSOR & CALIBRATION ================= */
const float VREF = 3.3;
const int SCOUNT = 30;
float PH_M = -8.04;
float PH_C = 26.17;
float NUTRIENT_M = -376.013;
float NUTRIENT_C = 1075.246;
float D_FULL = 1.0;
float D_EMPTY = 20.0;

/* ================= FIREBASE ================= */
void processData(AsyncResult &aResult);

UserAuth user_auth(Web_API_KEY, USER_EMAIL, USER_PASS);
FirebaseApp app;
WiFiClientSecure ssl_client1;  // Stream
WiFiClientSecure ssl_client2;  // Config (initialLoad, waterMax)
WiFiClientSecure ssl_client3;  // Sensor send
WiFiClientSecure ssl_client4;  // Device stream (calibration)
using AsyncClient = AsyncClientClass;
AsyncClient aClient1(ssl_client1);
AsyncClient aClient2(ssl_client2);
AsyncClient aClient3(ssl_client3);
AsyncClient aClient4(ssl_client4);
RealtimeDatabase Database;

String esp32Id;
bool streamStarted = false;
bool initialLoadDone = false;

/* ================= TIMING ================= */
unsigned long lastSend = 0;
unsigned long lastWaterMaxGet = 0;
const unsigned long WATER_MAX_INTERVAL = 30000;

/* ================= TDS BUFFER ================= */
int analogBuffer[SCOUNT];
int analogBufferIndex = 0;

/* ================= CACHED STATE ================= */
struct PumpState {
  String mode = "manual";
  bool isActived = false;
  bool prevActived = false;
  int failCount = 0;
};

PumpState waterState;
PumpState nutrientState;
PumpState phState;

/* ================= WATER PUMP ================= */
unsigned long waterPumpInterval = 300000;
unsigned long waterPumpDuration = 10000;
unsigned long lastWaterPumpStart = 0;
bool waterPumpRunning = false;

/* ================= NUTRIENT PUMP ================= */
unsigned long nutPumpInterval = 10000;
unsigned long nutPumpDuration = 300;
unsigned long nutPumpDurationPrime = 3000;
int nutTDSMin = 400;
unsigned long lastNutPumpStart = 0;
unsigned long lastNutActive = 0;
bool nutPumpRunning = false;
bool nutFirstDose = true;
// Durasi yang AKTIF saat pompa dinyalakan — tidak berubah di tengah jalan
unsigned long nutActiveDurLocked = 0;

/* ================= PH PUMP ================= */
unsigned long phPumpInterval = 10000;
unsigned long phPumpDuration = 300;
unsigned long phPumpDurationPrime = 3000;
float phMin = 6.0;
unsigned long lastPhPumpStart = 0;
unsigned long lastPhActive = 0;
bool phPumpRunning = false;
bool phFirstDose = true;
unsigned long phActiveDurLocked = 0;

/* ================== CALIBRATION STATE ================= */
struct CalibBuffer {
  bool mode = false;
  bool collecting = false;
  float sum = 0;
  int count = 0;
  unsigned long lastSample = 0;
};

CalibBuffer tdsA, tdsB, phA, phB;

unsigned long lastCalibCheck = 0;
const unsigned long CALIB_CHECK_INTERVAL = 3000;  // cek setiap 3 detik

/* ================= PRIME TIMEOUT ================= */
const unsigned long PRIME_TIMEOUT = 10UL * 60UL * 1000UL;

/* ================= HELPER ================= */
void setRelay(int pin, bool on, const char *label) {
  digitalWrite(pin, on ? LOW : HIGH);
  Serial.printf("[RELAY] %s → %s\n", label, on ? "ON" : "OFF");
}

/* ================== MEDIAN FILTER ================= */
int getMedianNum(int bArray[], int len) {
  int bTab[len];
  memcpy(bTab, bArray, len * sizeof(int));
  for (int j = 0; j < len - 1; j++)
    for (int i = 0; i < len - j - 1; i++)
      if (bTab[i] > bTab[i + 1]) {
        int tmp = bTab[i];
        bTab[i] = bTab[i + 1];
        bTab[i + 1] = tmp;
      }
  return (len % 2 == 1) ? bTab[len / 2] : (bTab[len / 2] + bTab[len / 2 - 1]) / 2;
}

/* ================== SENSOR FUNCTIONS ================= */
void readTdsSampling() {
  static unsigned long sampleTime = 0;
  if (millis() - sampleTime > 40) {
    sampleTime = millis();
    analogBuffer[analogBufferIndex++] = analogRead(TDS_PIN);
    if (analogBufferIndex >= SCOUNT) analogBufferIndex = 0;
  }
}

float readTdsValue() {
  int medianADC = getMedianNum(analogBuffer, SCOUNT);
  float voltage = medianADC * VREF / 4095.0;
  float tds = (NUTRIENT_M * voltage) + NUTRIENT_C;
  return (tds < 0) ? 0 : tds;
}

float readPhValue() {
  float total = 0;
  for (int i = 0; i < 10; i++) {
    total += analogRead(PH_PIN);
    delay(10);
  }
  float voltage = (total / 10.0) * VREF / 4095.0;
  return constrain(PH_M * voltage + PH_C, 0, 14);
}

float readDistanceCm() {
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(5);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);
  long duration = pulseIn(ECHO_PIN, HIGH, 60000);
  return (duration == 0) ? -1 : duration * 0.0343 / 2.0;
}

/* ================== EXTRACT FLOAT FROM JSON ================= */
float extractFloatFromJson(const String &json, const String &key) {
  String search = "\"" + key + "\":";
  int idx = json.indexOf(search);
  if (idx < 0) return 0;
  idx += search.length();
  int end = json.indexOf(',', idx);
  if (end < 0) end = json.indexOf('}', idx);
  String val = json.substring(idx, end);
  val.trim();
  return val.toFloat();
}

/* ================== PARSE STREAM ================= */
void parseStreamPayload(const String &path, const String &payload) {

  auto toBool = [](const String &s) {
    return s == "true" || s == "1";
  };

  auto extractStr = [&](const String &json, const String &key) -> String {
    String search = "\"" + key + "\":";
    int idx = json.indexOf(search);
    if (idx < 0) return "";
    idx += search.length();
    if (json[idx] == '"') {
      int end = json.indexOf('"', idx + 1);
      return json.substring(idx + 1, end);
    }
    int end = json.indexOf(',', idx);
    if (end < 0) end = json.indexOf('}', idx);
    return json.substring(idx, end);
  };

  auto extractSubJson = [&](const String &json, const String &key) -> String {
    String search = "\"" + key + "\":{";
    int start = json.indexOf(search);
    if (start < 0) return "";
    start = json.indexOf('{', start + search.length() - 1);
    int depth = 1, i = start + 1;
    while (i < (int)json.length() && depth > 0) {
      if (json[i] == '{') depth++;
      else if (json[i] == '}') depth--;
      i++;
    }
    return json.substring(start, i);
  };

  auto applyWater = [&](const String &j) {
    String v;
    v = extractStr(j, "mode");
    if (v.length()) waterState.mode = v;
    v = extractStr(j, "isActived");
    if (v.length()) waterState.isActived = toBool(v);
    v = extractStr(j, "interval");
    if (v.length()) waterPumpInterval = (unsigned long)v.toInt();
    v = extractStr(j, "duration");
    if (v.length()) waterPumpDuration = (unsigned long)v.toInt();
  };

  auto applyNutrient = [&](const String &j) {
    String v;
    v = extractStr(j, "mode");
    if (v.length()) nutrientState.mode = v;
    v = extractStr(j, "isActived");
    if (v.length()) {
      nutrientState.prevActived = nutrientState.isActived;
      nutrientState.isActived = toBool(v);
    }
    v = extractStr(j, "tds_min");
    if (v.length()) nutTDSMin = v.toInt();
    if (v.length()) nutPumpInterval = (unsigned long)v.toInt();
    v = extractStr(j, "duration");
    if (v.length()) nutPumpDuration = (unsigned long)v.toInt();
    v = extractStr(j, "duration_prime");
    if (v.length()) nutPumpDurationPrime = (unsigned long)v.toInt();
  };

  auto applyPh = [&](const String &j) {
    String v;
    v = extractStr(j, "mode");
    if (v.length()) phState.mode = v;
    v = extractStr(j, "isActived");
    if (v.length()) {
      phState.prevActived = phState.isActived;
      phState.isActived = toBool(v);
    }
    v = extractStr(j, "ph_min");
    if (v.length()) phMin = v.toFloat();
    v = extractStr(j, "interval");
    if (v.length()) phPumpInterval = (unsigned long)v.toInt();
    v = extractStr(j, "duration");
    if (v.length()) phPumpDuration = (unsigned long)v.toInt();
    v = extractStr(j, "duration_prime");
    if (v.length()) phPumpDurationPrime = (unsigned long)v.toInt();
  };

  // Initial full load
  if (path == "/" || path == "") {
    String wJson = extractSubJson(payload, "water");
    String nJson = extractSubJson(payload, "nutrient");
    String pJson = extractSubJson(payload, "ph");
    if (wJson.length()) applyWater(wJson);
    if (nJson.length()) applyNutrient(nJson);
    if (pJson.length()) applyPh(pJson);
    Serial.printf("[INIT] Water:%s(%s) Nut:%s(%s) PH:%s(%s)\n",
                  waterState.mode.c_str(), waterState.isActived ? "ON" : "OFF",
                  nutrientState.mode.c_str(), nutrientState.isActived ? "ON" : "OFF",
                  phState.mode.c_str(), phState.isActived ? "ON" : "OFF");
    return;
  }

  // Field tunggal — cek SEBELUM sub-node
  if (path == "/water/mode") {
    waterState.mode = payload;
    Serial.printf("[STREAM] water/mode=%s\n", payload.c_str());
    return;
  }
  if (path == "/water/isActived") {
    waterState.isActived = toBool(payload);
    Serial.printf("[STREAM] water/isActived=%s\n", payload.c_str());
    return;
  }
  if (path == "/water/interval") {
    waterPumpInterval = (unsigned long)payload.toInt();
    return;
  }
  if (path == "/water/duration") {
    waterPumpDuration = (unsigned long)payload.toInt();
    return;
  }

  if (path == "/nutrient/mode") {
    nutrientState.mode = payload;
    Serial.printf("[STREAM] nutrient/mode=%s\n", payload.c_str());
    return;
  }
  if (path == "/nutrient/isActived") {
    nutrientState.prevActived = nutrientState.isActived;
    nutrientState.isActived = toBool(payload);
    Serial.printf("[STREAM] nutrient/isActived=%s\n", payload.c_str());
    return;
  }
  if (path == "/nutrient/tds_min") {
    nutTDSMin = payload.toInt();
    return;
  }
  if (path == "/nutrient/interval") {
    nutPumpInterval = (unsigned long)payload.toInt();
    return;
  }
  if (path == "/nutrient/duration") {
    nutPumpDuration = (unsigned long)payload.toInt();
    return;
  }
  if (path == "/nutrient/duration_prime") {
    nutPumpDurationPrime = (unsigned long)payload.toInt();
    return;
  }

  if (path == "/ph/mode") {
    phState.mode = payload;
    Serial.printf("[STREAM] ph/mode=%s\n", payload.c_str());
    return;
  }
  if (path == "/ph/isActived") {
    phState.prevActived = phState.isActived;
    phState.isActived = toBool(payload);
    Serial.printf("[STREAM] ph/isActived=%s\n", payload.c_str());
    return;
  }
  if (path == "/ph/ph_min") {
    phMin = payload.toFloat();
    return;
  }
  if (path == "/ph/interval") {
    phPumpInterval = (unsigned long)payload.toInt();
    return;
  }
  if (path == "/ph/duration") {
    phPumpDuration = (unsigned long)payload.toInt();
    return;
  }
  if (path == "/ph/duration_prime") {
    phPumpDurationPrime = (unsigned long)payload.toInt();
    return;
  }

  // Sub-node JSON
  if (path == "/water") {
    applyWater(payload);
    return;
  }
  if (path == "/nutrient") {
    applyNutrient(payload);
    return;
  }
  if (path == "/ph") {
    applyPh(payload);
    return;
  }
}

/* ================== HANDLE PUMPS ================= */

void handleWaterPump() {
  if (!initialLoadDone) return;
  unsigned long now = millis();

  if (waterState.mode == "auto") {
    if (!waterPumpRunning && (lastWaterPumpStart == 0 || now - lastWaterPumpStart >= waterPumpInterval)) {
      setRelay(RELAY_WATER, true, "Water AUTO on");
      waterPumpRunning = true;
      lastWaterPumpStart = now;
    }
    if (waterPumpRunning && now - lastWaterPumpStart >= waterPumpDuration) {
      setRelay(RELAY_WATER, false, "Water AUTO off");
      waterPumpRunning = false;
      lastWaterPumpStart = now;
    }
  } else {
    bool target = waterState.isActived;
    if (waterPumpRunning != target) {
      setRelay(RELAY_WATER, target, "Water MANUAL");
      waterPumpRunning = target;
    }
  }
}

void handleNutrientPump() {
  if (!initialLoadDone) return;
  unsigned long now = millis();

  // Idle timeout → perlu prime lagi
  if (!nutPumpRunning && lastNutActive > 0 && (now - lastNutActive >= PRIME_TIMEOUT)) {
    if (!nutFirstDose) {
      nutFirstDose = true;
      Serial.println("[NUT] Idle — perlu prime lagi");
    }
  }

  // Auto-off: pakai nutActiveDurLocked yang di-set saat pompa dinyalakan
  // Sehingga perubahan nutFirstDose tidak mempengaruhi pompa yang sedang running
  if (nutPumpRunning && now - lastNutPumpStart >= nutActiveDurLocked) {
    setRelay(RELAY_NUTRIENT, false, nutActiveDurLocked == nutPumpDurationPrime ? "Nutrient prime selesai" : "Nutrient tetes selesai");
    nutPumpRunning = false;
    lastNutPumpStart = now;
    lastNutActive = now;
    nutFirstDose = false;
  }

  if (nutrientState.failCount >= 3) {
    if (nutPumpRunning) {
      setRelay(RELAY_NUTRIENT, false, "Nutrient FAILSAFE");
      nutPumpRunning = false;
    }
    return;
  }

  if (nutrientState.mode == "manual") {
    if (!nutrientState.prevActived && nutrientState.isActived && !nutPumpRunning) {
      nutActiveDurLocked = nutFirstDose ? nutPumpDurationPrime : nutPumpDuration;
      Serial.printf("[NUT] MANUAL dose %lums %s\n", nutActiveDurLocked, nutFirstDose ? "(PRIME)" : "");
      setRelay(RELAY_NUTRIENT, true, "Nutrient MANUAL");
      nutPumpRunning = true;
      lastNutPumpStart = now;
    }
    return;
  }

  // AUTO
  float tds = readTdsValue();
  if (tds < nutTDSMin) {
    if (!nutPumpRunning && (lastNutPumpStart == 0 || now - lastNutPumpStart >= nutPumpInterval)) {
      nutActiveDurLocked = nutFirstDose ? nutPumpDurationPrime : nutPumpDuration;
      Serial.printf("[NUT] AUTO dose TDS:%.0f %lums %s\n", tds, nutActiveDurLocked, nutFirstDose ? "(PRIME)" : "");
      setRelay(RELAY_NUTRIENT, true, "Nutrient AUTO");
      nutPumpRunning = true;
      lastNutPumpStart = now;
    }
  } else {
    if (nutPumpRunning) {
      setRelay(RELAY_NUTRIENT, false, "Nutrient AUTO stop");
      nutPumpRunning = false;
    }
    lastNutPumpStart = now;
  }
}

void handlePhPump() {
  if (!initialLoadDone) return;
  unsigned long now = millis();

  // Idle timeout → perlu prime lagi
  if (!phPumpRunning && lastPhActive > 0 && (now - lastPhActive >= PRIME_TIMEOUT)) {
    if (!phFirstDose) {
      phFirstDose = true;
      Serial.println("[PH] Idle — perlu prime lagi");
    }
  }

  // Auto-off: pakai phActiveDurLocked
  if (phPumpRunning && now - lastPhPumpStart >= phActiveDurLocked) {
    setRelay(RELAY_PH, false, phActiveDurLocked == phPumpDurationPrime ? "PH prime selesai" : "PH tetes selesai");
    phPumpRunning = false;
    lastPhPumpStart = now;
    lastPhActive = now;
    phFirstDose = false;
  }

  if (phState.failCount >= 3) {
    if (phPumpRunning) {
      setRelay(RELAY_PH, false, "PH FAILSAFE");
      phPumpRunning = false;
    }
    return;
  }

  if (phState.mode == "manual") {
    if (!phState.prevActived && phState.isActived && !phPumpRunning) {
      phActiveDurLocked = phFirstDose ? phPumpDurationPrime : phPumpDuration;
      Serial.printf("[PH] MANUAL dose %lums %s\n", phActiveDurLocked, phFirstDose ? "(PRIME)" : "");
      setRelay(RELAY_PH, true, "PH MANUAL");
      phPumpRunning = true;
      lastPhPumpStart = now;
    }
    return;
  }

  // AUTO
  float ph = readPhValue();
  if (ph < phMin) {
    if (!phPumpRunning && (lastPhPumpStart == 0 || now - lastPhPumpStart >= phPumpInterval)) {
      phActiveDurLocked = phFirstDose ? phPumpDurationPrime : phPumpDuration;
      Serial.printf("[PH] AUTO dose pH:%.2f %lums %s\n", ph, phActiveDurLocked, phFirstDose ? "(PRIME)" : "");
      setRelay(RELAY_PH, true, "PH AUTO");
      phPumpRunning = true;
      lastPhPumpStart = now;
    }
  } else {
    if (phPumpRunning) {
      setRelay(RELAY_PH, false, "PH AUTO stop");
      phPumpRunning = false;
    }
    lastPhPumpStart = now;
  }
}

/* ================== HANDLE CALIBRATION ================= */
void handleCalibration() {
  if (!initialLoadDone) return;
  unsigned long now = millis();
  String devPath = "/devices/" + esp32Id;

  // ─── TDS Buffer A ───
  if (tdsA.mode && !tdsA.collecting) {
    tdsA.collecting = true;
    tdsA.sum = 0;
    tdsA.count = 0;
    tdsA.lastSample = 0;
    Serial.println("[CALIB] TDS bufferA mulai sampling");
  }
  if (tdsA.collecting && now - tdsA.lastSample >= 200) {
    tdsA.lastSample = now;
    float v = analogRead(TDS_PIN) * (3.3f / 4095.0f);
    tdsA.sum += v;
    tdsA.count++;
    Serial.printf("[CALIB] TDS A sample %d: %.4fV\n", tdsA.count, v);

    if (tdsA.count >= 10) {
      float avg = tdsA.sum / 10.0f;
      Serial.printf("[CALIB] TDS bufferA avg: %.4fV → kirim\n", avg);

      object_t json, vTeg, vMode;
      JsonWriter writer;
      writer.create(vTeg, "tegangan", avg);
      writer.create(vMode, "mode", false);
      writer.join(json, 2, vTeg, vMode);
      Database.update<object_t>(aClient3, devPath + "/tds/bufferA", json, processData, "calibTdsA");

      tdsA.mode = false;
      tdsA.collecting = false;
    }
  }

  // ─── TDS Buffer B ───
  if (tdsB.mode && !tdsB.collecting) {
    tdsB.collecting = true;
    tdsB.sum = 0;
    tdsB.count = 0;
    tdsB.lastSample = 0;
    Serial.println("[CALIB] TDS bufferB mulai sampling");
  }
  if (tdsB.collecting && now - tdsB.lastSample >= 200) {
    tdsB.lastSample = now;
    float v = analogRead(TDS_PIN) * (3.3f / 4095.0f);
    tdsB.sum += v;
    tdsB.count++;
    Serial.printf("[CALIB] TDS B sample %d: %.4fV\n", tdsB.count, v);

    if (tdsB.count >= 10) {
      float avg = tdsB.sum / 10.0f;
      Serial.printf("[CALIB] TDS bufferB avg: %.4fV → kirim\n", avg);

      object_t json, vTeg, vMode;
      JsonWriter writer;
      writer.create(vTeg, "tegangan", avg);
      writer.create(vMode, "mode", false);
      writer.join(json, 2, vTeg, vMode);
      Database.update<object_t>(aClient3, devPath + "/tds/bufferB", json, processData, "calibTdsB");

      tdsB.mode = false;
      tdsB.collecting = false;
    }
  }

  // ─── PH Buffer A ───
  if (phA.mode && !phA.collecting) {
    phA.collecting = true;
    phA.sum = 0;
    phA.count = 0;
    phA.lastSample = 0;
    Serial.println("[CALIB] PH bufferA mulai sampling");
  }
  if (phA.collecting && now - phA.lastSample >= 200) {
    phA.lastSample = now;
    float v = analogRead(PH_PIN) * (3.3f / 4095.0f);
    phA.sum += v;
    phA.count++;
    Serial.printf("[CALIB] PH A sample %d: %.4fV\n", phA.count, v);

    if (phA.count >= 10) {
      float avg = phA.sum / 10.0f;
      Serial.printf("[CALIB] PH bufferA avg: %.4fV → kirim\n", avg);

      object_t json, vTeg, vMode;
      JsonWriter writer;
      writer.create(vTeg, "tegangan", avg);
      writer.create(vMode, "mode", false);
      writer.join(json, 2, vTeg, vMode);
      Database.update<object_t>(aClient3, devPath + "/ph/bufferA", json, processData, "calibPhA");

      phA.mode = false;
      phA.collecting = false;
    }
  }

  // ─── PH Buffer B ───
  if (phB.mode && !phB.collecting) {
    phB.collecting = true;
    phB.sum = 0;
    phB.count = 0;
    phB.lastSample = 0;
    Serial.println("[CALIB] PH bufferB mulai sampling");
  }
  if (phB.collecting && now - phB.lastSample >= 200) {
    phB.lastSample = now;
    float v = analogRead(PH_PIN) * (3.3f / 4095.0f);
    phB.sum += v;
    phB.count++;
    Serial.printf("[CALIB] PH B sample %d: %.4fV\n", phB.count, v);

    if (phB.count >= 10) {
      float avg = phB.sum / 10.0f;
      Serial.printf("[CALIB] PH bufferB avg: %.4fV → kirim\n", avg);

      object_t json, vTeg, vMode;
      JsonWriter writer;
      writer.create(vTeg, "tegangan", avg);
      writer.create(vMode, "mode", false);
      writer.join(json, 2, vTeg, vMode);
      Database.update<object_t>(aClient3, devPath + "/ph/bufferB", json, processData, "calibPhB");

      phB.mode = false;
      phB.collecting = false;
    }
  }
}

/* ================== FIREBASE CALLBACK ================= */
void processData(AsyncResult &aResult) {
  if (!aResult.isResult()) return;

  if (aResult.isError()) {
    Firebase.printf("[FB ERR] %s: %s (%d)\n",
                    aResult.uid().c_str(),
                    aResult.error().message().c_str(),
                    aResult.error().code());
    return;
  }

  if (aResult.available()) {
    RealtimeDatabaseResult &RTDB = aResult.to<RealtimeDatabaseResult>();

    if (RTDB.isStream()) {
      parseStreamPayload(RTDB.dataPath().c_str(), RTDB.to<String>().c_str());
      return;
    }

    if (aResult.uid() == "initialLoad") {
      parseStreamPayload("/", RTDB.to<String>().c_str());
      initialLoadDone = true;
      Serial.println("[INIT] Done — pompa siap");
      return;
    }

    if (aResult.uid() == "getWaterMax") {
      float f = RTDB.to<String>().toFloat();
      if (f > 0) {
        D_EMPTY = f;
        Serial.printf("[CFG] water_max=%.1fcm\n", D_EMPTY);
      }
      return;
    }

    if (aResult.uid() == "getTdsCalib") {
      String json = RTDB.to<String>();
      float gradien = extractFloatFromJson(json, "gradien");
      float konstanta = extractFloatFromJson(json, "konstanta");
      if (gradien != 0) {
        NUTRIENT_M = gradien;
        Serial.printf("[CFG] TDS gradien=%.4f\n", NUTRIENT_M);
      }
      if (konstanta != 0) {
        NUTRIENT_C = konstanta;
        Serial.printf("[CFG] TDS konstanta=%.4f\n", NUTRIENT_C);
      }
      return;
    }

    if (aResult.uid() == "getPhCalib") {
      String json = RTDB.to<String>();
      float gradien = extractFloatFromJson(json, "gradien");
      float konstanta = extractFloatFromJson(json, "konstanta");
      if (gradien != 0) {
        PH_M = gradien;
        Serial.printf("[CFG] pH gradien=%.4f\n", PH_M);
      }
      if (konstanta != 0) {
        PH_C = konstanta;
        Serial.printf("[CFG] pH konstanta=%.4f\n", PH_C);
      }
      return;
    }

    if (aResult.uid() == "getTdsAMode") {
      tdsA.mode = (RTDB.to<String>() == "true");
      Serial.printf("[CFG] tdsA.mode=%d\n", tdsA.mode);
      return;
    }
    if (aResult.uid() == "getTdsBMode") {
      tdsB.mode = (RTDB.to<String>() == "true");
      return;
    }
    if (aResult.uid() == "getPhAMode") {
      phA.mode = (RTDB.to<String>() == "true");
      return;
    }
    if (aResult.uid() == "getPhBMode") {
      phB.mode = (RTDB.to<String>() == "true");
      return;
    }
  }
}

void processDeviceStream(AsyncResult &aResult) {
  if (!aResult.isResult()) return;
  if (aResult.isError()) {
    Firebase.printf("[DEV ERR] %s: %s (%d)\n",
                    aResult.uid().c_str(),
                    aResult.error().message().c_str(),
                    aResult.error().code());
    return;
  }
  if (aResult.available()) {
    RealtimeDatabaseResult &RTDB = aResult.to<RealtimeDatabaseResult>();

    Serial.printf("[DEV RAW] isStream:%d path:%s payload:%s\n",
                  RTDB.isStream(),
                  RTDB.dataPath().c_str(),
                  RTDB.to<String>().c_str());

    if (!RTDB.isStream()) return;

    String path = RTDB.dataPath().c_str();
    String payload = RTDB.to<String>().c_str();

    // Abaikan initial snapshot (path "/" dari deviceStream)
    if (path == "/" || path == "") return;

    // Hanya handle calib mode
    auto toBool = [](const String &s) {
      return s == "true" || s == "1";
    };

    if (path == "/tds/bufferA/mode") {
      tdsA.mode = toBool(payload);
      Serial.printf("[DEV STREAM] tds/bufferA/mode=%s\n", payload.c_str());
      return;
    }
    if (path == "/tds/bufferB/mode") {
      tdsB.mode = toBool(payload);
      Serial.printf("[DEV STREAM] tds/bufferB/mode=%s\n", payload.c_str());
      return;
    }
    if (path == "/ph/bufferA/mode") {
      phA.mode = toBool(payload);
      Serial.printf("[DEV STREAM] ph/bufferA/mode=%s\n", payload.c_str());
      return;
    }
    if (path == "/ph/bufferB/mode") {
      phB.mode = toBool(payload);
      Serial.printf("[DEV STREAM] ph/bufferB/mode=%s\n", payload.c_str());
      return;
    }
  }
}

/* ================== SETUP & LOOP ================= */
void setup() {
  Serial.begin(115200);
  delay(1000);  // ← tambah ini, biar Serial sempat init dulu
  Serial.println("Booting..");

  pinMode(RELAY_PH, OUTPUT);
  digitalWrite(RELAY_PH, HIGH);
  pinMode(RELAY_WATER, OUTPUT);
  digitalWrite(RELAY_WATER, HIGH);
  pinMode(RELAY_NUTRIENT, OUTPUT);
  digitalWrite(RELAY_NUTRIENT, HIGH);
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(300);
    Serial.print(".");
  }
  Serial.println(" OK");

  configTime(0, 0, "pool.ntp.org", "time.nist.gov");
  Serial.print("Sync time");
  while (time(nullptr) < 100000) {
    delay(500);
    Serial.print(".");
  }
  Serial.println(" OK");

  esp32Id = WiFi.macAddress();
  esp32Id.replace(":", "");
  Serial.printf("ESP32 ID: %s\n", esp32Id.c_str());

  ssl_client1.setInsecure();
  ssl_client1.setConnectionTimeout(1000);
  ssl_client1.setHandshakeTimeout(5);
  ssl_client2.setInsecure();
  ssl_client2.setConnectionTimeout(1000);
  ssl_client2.setHandshakeTimeout(5);
  ssl_client3.setInsecure();
  ssl_client3.setConnectionTimeout(1000);
  ssl_client3.setHandshakeTimeout(5);
  ssl_client4.setInsecure();
  ssl_client4.setConnectionTimeout(1000);
  ssl_client4.setHandshakeTimeout(5);

  initializeApp(aClient1, app, getAuth(user_auth), processData, "authTask");
  app.getApp<RealtimeDatabase>(Database);
  Database.url(DATABASE_URL);
}

void loop() {
  app.loop();

  readTdsSampling();
  handleWaterPump();
  handleNutrientPump();
  handlePhPump();
  handleCalibration();

  if (app.ready() && !streamStarted) {
    streamStarted = true;
    String controlPath = "/control/" + esp32Id;
    Database.get(aClient2, controlPath, processData, false, "initialLoad");
    Database.get(aClient1, controlPath, processData, true, "controlStream");
    Database.get(aClient2, "/devices/" + esp32Id + "/water_max", processData, false, "getWaterMax");
    Database.get(aClient2, "/devices/" + esp32Id + "/tds", processData, false, "getTdsCalib");
    Database.get(aClient2, "/devices/" + esp32Id + "/ph", processData, false, "getPhCalib");
    Database.get(aClient4, "/devices/" + esp32Id, processDeviceStream, true, "deviceStream");
    lastWaterMaxGet = millis();
    Serial.println("[BOOT] Stream + initial load started");
  }

  if (app.ready() && streamStarted && millis() - lastWaterMaxGet >= WATER_MAX_INTERVAL) {
    lastWaterMaxGet = millis();
    Database.get(aClient2, "/devices/" + esp32Id + "/water_max", processData, false, "getWaterMax");
  }

  if (app.ready() && initialLoadDone && millis() - lastCalibCheck >= CALIB_CHECK_INTERVAL) {
    lastCalibCheck = millis();
    String dp = "/devices/" + esp32Id;
    Database.get(aClient2, dp + "/tds/bufferA/mode", processData, false, "getTdsAMode");
    Database.get(aClient2, dp + "/tds/bufferB/mode", processData, false, "getTdsBMode");
    Database.get(aClient2, dp + "/ph/bufferA/mode", processData, false, "getPhAMode");
    Database.get(aClient2, dp + "/ph/bufferB/mode", processData, false, "getPhBMode");
  }

  if (app.ready() && initialLoadDone && millis() - lastSend >= 5000) {
    lastSend = millis();

    float ph = readPhValue();
    float tds = readTdsValue();
    float dist = readDistanceCm();
    
    float waterLevel;
    if (dist >= D_EMPTY) {
      waterLevel = 100.0f;
    } else if (dist <= D_FULL) {
      waterLevel = 0.0f;
    } else {
      waterLevel = (dist - D_FULL) * 100.0f / (D_EMPTY - D_FULL);
    }

    object_t json, v1, v2, v3, v4;
    JsonWriter writer;
    writer.create(v1, "ph", ph);
    writer.create(v2, "tds", tds);
    writer.create(v3, "water_level", waterLevel);
    writer.create(v4, "updated_at", (int)millis());
    writer.join(json, 4, v1, v2, v3, v4);

    Database.set<object_t>(aClient3, "/sensor_data/" + esp32Id, json, processData, "sensorSend");
    Database.set<int64_t>(aClient3, "/devices/" + esp32Id + "/last_seen",
                          (int64_t)(time(nullptr) * 1000LL), processData, "lastSeen");

    Serial.printf("[DATA] WL:%.0f%% pH:%.2f TDS:%.0f | W:%s N:%s P:%s\n",
                  waterLevel, ph, tds,
                  waterPumpRunning ? "ON" : "OFF",
                  nutPumpRunning ? "ON" : "OFF",
                  phPumpRunning ? "ON" : "OFF");
  }
}