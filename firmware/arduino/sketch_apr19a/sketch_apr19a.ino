#define ENABLE_USER_AUTH
#define ENABLE_DATABASE

#include <Arduino.h>
#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <FirebaseClient.h>

/* ================= WIFI & FIREBASE ================= */
#define WIFI_SSID       "WASIS FAMILY"
#define WIFI_PASSWORD   "01021969"
#define Web_API_KEY     "AIzaSyCIhqKK-UMKd_Jmw4WGEWojye8P_zNBOro"
#define DATABASE_URL    "https://smart-hydroponic-14bcf-default-rtdb.asia-southeast1.firebasedatabase.app"
#define USER_EMAIL      "zerxonin@gmail.com"
#define USER_PASS       "123456"

/* ================= PIN DEFINITION ================= */
#define RELAY_PH       25
#define RELAY_NUTRIENT 26
#define RELAY_WATER    27
#define TRIG_PIN       19
#define ECHO_PIN       18
#define TDS_PIN        35
#define PH_PIN         34

/* ================= SENSOR & CALIBRATION ================= */
const float VREF   = 3.3;
const int   SCOUNT = 30;
const float PH_M   = -19.35;
const float PH_C   = 32.13;
float D_FULL  = 1.0;
float D_EMPTY = 20.0;

/* ================= FIREBASE ================= */
void processData(AsyncResult &aResult);

UserAuth user_auth(Web_API_KEY, USER_EMAIL, USER_PASS);
FirebaseApp app;
WiFiClientSecure ssl_client1; // Stream kontrol
WiFiClientSecure ssl_client2; // Kirim sensor + get config
using AsyncClient = AsyncClientClass;
AsyncClient aClient1(ssl_client1);
AsyncClient aClient2(ssl_client2);
RealtimeDatabase Database;

String esp32Id;
bool streamStarted = false;

/* ================= TIMING ================= */
unsigned long lastSend       = 0;
unsigned long lastWaterMaxGet = 0;
const unsigned long WATER_MAX_INTERVAL = 30000; // Ambil water_max tiap 30 detik

/* ================= TDS BUFFER ================= */
int analogBuffer[SCOUNT];
int analogBufferIndex = 0;

/* ================= CACHED STATE ================= */
struct PumpState {
  String mode        = "manual";
  bool   isActived   = false;
  bool   prevActived = false;
  int    failCount   = 0;
};

PumpState waterState;
PumpState nutrientState;
PumpState phState;

/* ================= WATER PUMP CONFIG ================= */
unsigned long waterPumpInterval  = 300000;
unsigned long waterPumpDuration  = 10000;
unsigned long lastWaterPumpStart = 0;
bool          waterPumpRunning   = false;

/* ================= NUTRIENT PUMP CONFIG ================= */
unsigned long nutPumpInterval      = 30000; // 30 detik antar dosis
unsigned long nutPumpDuration      = 100;   // durasi normal — kalibrasi dulu
unsigned long nutPumpDurationPrime = 3000;  // durasi prime selang kosong — kalibrasi dulu
int           nutTDSMin            = 400;
int           nutTDSMax            = 1000;
unsigned long lastNutPumpStart     = 0;
unsigned long lastNutActive        = 0;
bool          nutPumpRunning       = false;
bool          nutFirstDose         = true;

/* ================= PH PUMP CONFIG ================= */
unsigned long phPumpInterval      = 30000;
unsigned long phPumpDuration      = 100;
unsigned long phPumpDurationPrime = 3000;
float         phMin               = 6.0;
unsigned long lastPhPumpStart     = 0;
unsigned long lastPhActive        = 0;
bool          phPumpRunning       = false;
bool          phFirstDose         = true;

/* ================= PRIME TIMEOUT ================= */
const unsigned long PRIME_TIMEOUT = 10UL * 60UL * 1000UL; // 10 menit

/* ================= HELPER ================= */
void setRelay(int pin, bool on, const char* label) {
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
        int tmp = bTab[i]; bTab[i] = bTab[i+1]; bTab[i+1] = tmp;
      }
  return (len % 2 == 1) ? bTab[len/2] : (bTab[len/2] + bTab[len/2-1]) / 2;
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
  float tds = (-376.013 * voltage) + 1075.246;
  return (tds < 0) ? 0 : tds;
}

float readPhValue() {
  float total = 0;
  for (int i = 0; i < 10; i++) { total += analogRead(PH_PIN); delay(10); }
  float voltage = (total / 10.0) * VREF / 4095.0;
  return constrain(PH_M * voltage + PH_C, 0, 14);
}

float readDistanceCm() {
  digitalWrite(TRIG_PIN, LOW); delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH); delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);
  long duration = pulseIn(ECHO_PIN, HIGH, 30000);
  return (duration == 0) ? -1 : duration / 58.0;
}

/* =================================================
   PARSE STREAM
   ================================================= */
void parseStreamPayload(const String &path, const String &payload) {
  Serial.printf("[STREAM] path:%s data:%s\n", path.c_str(), payload.c_str());

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

  // ── Field tunggal ──
  if (path == "/water/mode")              { waterState.mode = payload; return; }
  if (path == "/water/isActived")         { waterState.isActived = toBool(payload); return; }
  if (path == "/water/interval")          { waterPumpInterval = payload.toInt(); return; }
  if (path == "/water/duration")          { waterPumpDuration = payload.toInt(); return; }

  if (path == "/nutrient/mode")           { nutrientState.mode = payload; return; }
  if (path == "/nutrient/isActived")      {
    nutrientState.prevActived = nutrientState.isActived;
    nutrientState.isActived   = toBool(payload);
    Serial.printf("[STREAM] Nutrient isActived: %s → %s\n",
      nutrientState.prevActived ? "true":"false",
      nutrientState.isActived   ? "true":"false");
    return;
  }
  if (path == "/nutrient/tds_min")        { nutTDSMin = payload.toInt(); return; }
  if (path == "/nutrient/tds_max")        { nutTDSMax = payload.toInt(); return; }
  if (path == "/nutrient/interval")       { nutPumpInterval = (unsigned long)payload.toInt(); return; }
  if (path == "/nutrient/duration")       { nutPumpDuration = (unsigned long)payload.toInt(); return; }
  if (path == "/nutrient/duration_prime") { nutPumpDurationPrime = (unsigned long)payload.toInt(); return; }

  if (path == "/ph/mode")                 { phState.mode = payload; return; }
  if (path == "/ph/isActived")            {
    phState.prevActived = phState.isActived;
    phState.isActived   = toBool(payload);
    Serial.printf("[STREAM] PH isActived: %s → %s\n",
      phState.prevActived ? "true":"false",
      phState.isActived   ? "true":"false");
    return;
  }
  if (path == "/ph/ph_min")               { phMin = payload.toFloat(); return; }
  if (path == "/ph/interval")             { phPumpInterval = (unsigned long)payload.toInt(); return; }
  if (path == "/ph/duration")             { phPumpDuration = (unsigned long)payload.toInt(); return; }
  if (path == "/ph/duration_prime")       { phPumpDurationPrime = (unsigned long)payload.toInt(); return; }

  // ── JSON sub-node atau initial load ──
  auto parseWater = [&](const String &j) {
    String v;
    v = extractStr(j, "mode");      if (v.length()) waterState.mode = v;
    v = extractStr(j, "isActived"); if (v.length()) waterState.isActived = toBool(v);
    v = extractStr(j, "interval");  if (v.length()) waterPumpInterval = v.toInt();
    v = extractStr(j, "duration");  if (v.length()) waterPumpDuration = v.toInt();
  };

  auto parseNutrient = [&](const String &j) {
    String v;
    v = extractStr(j, "mode");           if (v.length()) nutrientState.mode = v;
    v = extractStr(j, "isActived");      if (v.length()) {
      nutrientState.prevActived = nutrientState.isActived;
      nutrientState.isActived   = toBool(v);
    }
    v = extractStr(j, "tds_min");        if (v.length()) nutTDSMin = v.toInt();
    v = extractStr(j, "tds_max");        if (v.length()) nutTDSMax = v.toInt();
    v = extractStr(j, "interval");       if (v.length()) nutPumpInterval = v.toInt();
    v = extractStr(j, "duration");       if (v.length()) nutPumpDuration = v.toInt();
    v = extractStr(j, "duration_prime"); if (v.length()) nutPumpDurationPrime = v.toInt();
  };

  auto parsePh = [&](const String &j) {
    String v;
    v = extractStr(j, "mode");           if (v.length()) phState.mode = v;
    v = extractStr(j, "isActived");      if (v.length()) {
      phState.prevActived = phState.isActived;
      phState.isActived   = toBool(v);
    }
    v = extractStr(j, "ph_min");         if (v.length()) phMin = v.toFloat();
    v = extractStr(j, "interval");       if (v.length()) phPumpInterval = v.toInt();
    v = extractStr(j, "duration");       if (v.length()) phPumpDuration = v.toInt();
    v = extractStr(j, "duration_prime"); if (v.length()) phPumpDurationPrime = v.toInt();
  };

  if (path == "/water"    || path.startsWith("/water"))    { parseWater(payload);    return; }
  if (path == "/nutrient" || path.startsWith("/nutrient")) { parseNutrient(payload); return; }
  if (path == "/ph"       || path.startsWith("/ph"))       { parsePh(payload);       return; }

  // Initial full load — path == "/"
  if (path == "/" || path == "") {
    // Cari dan parse masing-masing sub-node dari JSON root
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

    String wJson = extractSubJson(payload, "water");
    String nJson = extractSubJson(payload, "nutrient");
    String pJson = extractSubJson(payload, "ph");

    if (wJson.length()) parseWater(wJson);
    if (nJson.length()) parseNutrient(nJson);
    if (pJson.length()) parsePh(pJson);
  }
}

/* ================== HANDLE PUMPS ================= */

void handleWaterPump() {
  unsigned long now = millis();

  if (waterState.mode == "auto") {
    if (!waterPumpRunning && (lastWaterPumpStart == 0 || now - lastWaterPumpStart >= waterPumpInterval)) {
      setRelay(RELAY_WATER, true, "Water AUTO on");
      waterPumpRunning = true; lastWaterPumpStart = now;
    }
    if (waterPumpRunning && now - lastWaterPumpStart >= waterPumpDuration) {
      setRelay(RELAY_WATER, false, "Water AUTO off");
      waterPumpRunning = false; lastWaterPumpStart = now;
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
  unsigned long now = millis();

  // Idle timeout → perlu prime lagi
  if (!nutPumpRunning && lastNutActive > 0 && (now - lastNutActive >= PRIME_TIMEOUT)) {
    if (!nutFirstDose) {
      nutFirstDose = true;
      Serial.println("[NUT] Idle timeout — selang perlu prime lagi");
    }
  }

  // Auto-off setelah durasi habis (berlaku semua mode)
  unsigned long activeDur = nutFirstDose ? nutPumpDurationPrime : nutPumpDuration;
  if (nutPumpRunning && now - lastNutPumpStart >= activeDur) {
    setRelay(RELAY_NUTRIENT, false, nutFirstDose ? "Nutrient prime selesai" : "Nutrient tetes selesai");
    nutPumpRunning   = false;
    lastNutPumpStart = now;
    lastNutActive    = now;
    nutFirstDose     = false;
  }

  if (nutrientState.failCount >= 3) {
    if (nutPumpRunning) { setRelay(RELAY_NUTRIENT, false, "Nutrient FAILSAFE"); nutPumpRunning = false; }
    return;
  }

  if (nutrientState.mode == "manual") {
    // Rising edge → 1 dosis
    if (!nutrientState.prevActived && nutrientState.isActived && !nutPumpRunning) {
      activeDur = nutFirstDose ? nutPumpDurationPrime : nutPumpDuration;
      Serial.printf("[NUT] MANUAL — dur:%lums %s\n", activeDur, nutFirstDose ? "(PRIME)":"");
      setRelay(RELAY_NUTRIENT, true, "Nutrient MANUAL");
      nutPumpRunning = true; lastNutPumpStart = now;
    }
    return;
  }

  // AUTO
  float tds = readTdsValue();
  Serial.printf("[NUT AUTO] TDS:%.0f min:%d elapsed:%lus %s\n",
    tds, nutTDSMin, (now - lastNutPumpStart) / 1000, nutFirstDose ? "(PRIME READY)":"");

  if (tds < nutTDSMin) {
    if (!nutPumpRunning && (lastNutPumpStart == 0 || now - lastNutPumpStart >= nutPumpInterval)) {
      activeDur = nutFirstDose ? nutPumpDurationPrime : nutPumpDuration;
      Serial.printf("[NUT] AUTO dose — dur:%lums %s\n", activeDur, nutFirstDose ? "(PRIME)":"");
      setRelay(RELAY_NUTRIENT, true, "Nutrient AUTO");
      nutPumpRunning = true; lastNutPumpStart = now;
    }
  } else {
    if (nutPumpRunning) { setRelay(RELAY_NUTRIENT, false, "Nutrient AUTO stop"); nutPumpRunning = false; }
    lastNutPumpStart = now;
  }
}

void handlePhPump() {
  unsigned long now = millis();

  // Idle timeout → perlu prime lagi
  if (!phPumpRunning && lastPhActive > 0 && (now - lastPhActive >= PRIME_TIMEOUT)) {
    if (!phFirstDose) {
      phFirstDose = true;
      Serial.println("[PH] Idle timeout — selang perlu prime lagi");
    }
  }

  // Auto-off setelah durasi habis (berlaku semua mode)
  unsigned long activeDur = phFirstDose ? phPumpDurationPrime : phPumpDuration;
  if (phPumpRunning && now - lastPhPumpStart >= activeDur) {
    setRelay(RELAY_PH, false, phFirstDose ? "PH prime selesai" : "PH tetes selesai");
    phPumpRunning   = false;
    lastPhPumpStart = now;
    lastPhActive    = now;
    phFirstDose     = false;
  }

  if (phState.failCount >= 3) {
    if (phPumpRunning) { setRelay(RELAY_PH, false, "PH FAILSAFE"); phPumpRunning = false; }
    return;
  }

  if (phState.mode == "manual") {
    if (!phState.prevActived && phState.isActived && !phPumpRunning) {
      activeDur = phFirstDose ? phPumpDurationPrime : phPumpDuration;
      Serial.printf("[PH] MANUAL — dur:%lums %s\n", activeDur, phFirstDose ? "(PRIME)":"");
      setRelay(RELAY_PH, true, "PH MANUAL");
      phPumpRunning = true; lastPhPumpStart = now;
    }
    return;
  }

  // AUTO
  float ph = readPhValue();
  Serial.printf("[PH AUTO] pH:%.2f min:%.1f elapsed:%lus %s\n",
    ph, phMin, (now - lastPhPumpStart) / 1000, phFirstDose ? "(PRIME READY)":"");

  if (ph < phMin) {
    if (!phPumpRunning && (lastPhPumpStart == 0 || now - lastPhPumpStart >= phPumpInterval)) {
      activeDur = phFirstDose ? phPumpDurationPrime : phPumpDuration;
      Serial.printf("[PH] AUTO dose — dur:%lums %s\n", activeDur, phFirstDose ? "(PRIME)":"");
      setRelay(RELAY_PH, true, "PH AUTO");
      phPumpRunning = true; lastPhPumpStart = now;
    }
  } else {
    if (phPumpRunning) { setRelay(RELAY_PH, false, "PH AUTO stop"); phPumpRunning = false; }
    lastPhPumpStart = now;
  }
}

/* ================== FIREBASE CALLBACK ================= */
void processData(AsyncResult &aResult) {
  if (!aResult.isResult()) return;

  if (aResult.isError()) {
    Firebase.printf("[FB ERROR] task:%s msg:%s code:%d\n",
      aResult.uid().c_str(),
      aResult.error().message().c_str(),
      aResult.error().code());
    return;
  }

  if (aResult.available()) {
    RealtimeDatabaseResult &RTDB = aResult.to<RealtimeDatabaseResult>();

    // Stream kontrol
    if (RTDB.isStream()) {
      parseStreamPayload(RTDB.dataPath().c_str(), RTDB.to<String>().c_str());
      return;
    }

    // Hasil get water_max
    if (aResult.uid() == "getWaterMax") {
      float val = RTDB.to<float>();
      if (val > 0) {
        D_EMPTY = val;
        Serial.printf("[CONFIG] water_max updated: %.1f cm\n", D_EMPTY);
      }
      return;
    }
  }
}

/* ================== SETUP & LOOP ================= */
void setup() {
  Serial.begin(115200);

  pinMode(RELAY_PH,       OUTPUT); digitalWrite(RELAY_PH,       HIGH);
  pinMode(RELAY_WATER,    OUTPUT); digitalWrite(RELAY_WATER,    HIGH);
  pinMode(RELAY_NUTRIENT, OUTPUT); digitalWrite(RELAY_NUTRIENT, HIGH);
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting WiFi");
  while (WiFi.status() != WL_CONNECTED) { delay(300); Serial.print("."); }
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

  initializeApp(aClient1, app, getAuth(user_auth), processData, "authTask");
  app.getApp<RealtimeDatabase>(Database);
  Database.url(DATABASE_URL);
}

void loop() {
  // Wajib pertama — jalankan semua task async
  app.loop();

  readTdsSampling();
  handleWaterPump();
  handleNutrientPump();
  handlePhPump();

  // Start stream setelah auth siap — hanya sekali
  if (app.ready() && !streamStarted) {
    streamStarted = true;
    String streamPath = "/control/" + esp32Id;
    Database.get(aClient1, streamPath, processData, true, "controlStream");
    Serial.printf("[STREAM] Started: %s\n", streamPath.c_str());

    // Ambil water_max pertama kali
    Database.get<float>(aClient2, "/devices/" + esp32Id + "/water_max", processData, "getWaterMax");
    lastWaterMaxGet = millis();
  }

  // Ambil water_max periodik (tiap 30 detik)
  if (app.ready() && streamStarted && millis() - lastWaterMaxGet >= WATER_MAX_INTERVAL) {
    lastWaterMaxGet = millis();
    Database.get<float>(aClient2, "/devices/" + esp32Id + "/water_max", processData, "getWaterMax");
  }

  // Kirim sensor data tiap 5 detik
  if (app.ready() && streamStarted && millis() - lastSend >= 5000) {
    lastSend = millis();

    float ph         = readPhValue();
    float tds        = readTdsValue();
    float dist       = readDistanceCm();
    float waterLevel = (dist > 0)
      ? constrain((D_EMPTY - dist) / (D_EMPTY - D_FULL) * 100.0, 0, 100) : 0;

    object_t json, v1, v2, v3, v4;
    JsonWriter writer;
    writer.create(v1, "ph",          ph);
    writer.create(v2, "tds",         tds);
    writer.create(v3, "water_level", waterLevel);
    writer.create(v4, "updated_at",  (int)millis());
    writer.join(json, 4, v1, v2, v3, v4);

    Database.set<object_t>(aClient2, "/sensor_data/" + esp32Id, json, processData, "sensorSend");
    Database.set<int>(aClient2, "/devices/" + esp32Id + "/last_seen",
      (int)(millis()), processData, "lastSeen");

    Serial.printf("WL:%.1f%% pH:%.2f TDS:%.0fppm | W:%s N:%s P:%s | NF:%s PF:%s\n",
      waterLevel, ph, tds,
      waterPumpRunning ? "ON":"OFF",
      nutPumpRunning   ? "ON":"OFF",
      phPumpRunning    ? "ON":"OFF",
      nutFirstDose     ? "Y":"N",
      phFirstDose      ? "Y":"N");
  }
}