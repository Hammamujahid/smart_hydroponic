#define ENABLE_USER_AUTH
#define ENABLE_DATABASE

#include <Arduino.h>
#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <FirebaseClient.h>
#include <stdlib.h>

/* ================= WIFI & FIREBASE ================= */
// #define WIFI_SSID "WASI FAMILY_Plus"
// #define WIFI_SSID "WASI FAMILY"
// #define WIFI_PASSWORD "01021969"
#define WIFI_SSID "Aku Siapa"
#define WIFI_PASSWORD "Hehehehehehe"
#define Web_API_KEY "AIzaSyCIhqKK-UMKd_Jmw4WGEWojye8P_zNBOro"
#define DATABASE_URL "https://smart-hydroponic-14bcf-default-rtdb.asia-southeast1.firebasedatabase.app"
#define USER_EMAIL "zerxonin@gmail.com"
#define USER_PASS "123456"

/* ================= PIN DEFINITION ================= */
#define RELAY_NUTRIENT2 25
#define RELAY_NUTRIENT 26
#define RELAY_PH 27
#define RELAY_WATER 14
#define TRIG_PIN 19
#define ECHO_PIN 18
#define TDS_PIN 35
#define PH_PIN 34

/* ================= SENSOR ================= */
const float VREF = 3.3;
const int SCOUNT = 30;

/* ================= STATE CONTROL ================= */
String nut_mode = "manual";
bool nut_isActived = false;
int nut_tdsMin = 800;
unsigned long nut_duration = 5000;
unsigned long nut_interval = 180000;

String ph_mode = "manual";
bool ph_isActived = false;
float ph_min = 5.0;
unsigned long ph_duration = 5000;
unsigned long ph_interval = 180000;
 
String wat_mode = "manual";
bool wat_isActived = false;
unsigned long wat_duration = 15000;
unsigned long wat_interval = 20000;

unsigned long lastNutrientStart = 0;
unsigned long lastPhStart = 0;

/* ================= STATE DEVICES ================= */
float NUTRIENT_M = -376.013;
float NUTRIENT_C = 1075.246;
float PH_M = -8.04;
float PH_C = 26.17;
float D_FULL = 1.0;
float D_EMPTY = 20.0;
#define CALIB_SAMPLE_COUNT 30


struct CalibBuffer {
  bool mode = false;
  bool collecting = false;
  float samples[CALIB_SAMPLE_COUNT];
  int count = 0;
  unsigned long lastSample = 0;
};

CalibBuffer tdsA, tdsB, phA, phB;

unsigned long lastSeenSend = 0;
const unsigned long LAST_SEEN_INTERVAL = 30000;

bool waterRunning = false;
bool nutrientRunning = false;
bool phRunning = false;

unsigned long lastWaterStart = 0;

/* ================= SENSOR_DATA ================= */
unsigned long lastSensorSend = 0;
const unsigned long SENSOR_INTERVAL = 5000;

int analogBuffer[SCOUNT];
int analogBufferIndex = 0;

/* ================= FIREBASE ================= */
String esp32Id;
bool streamStarted = false;
bool configLoaded = false;

void processControl(AsyncResult &aResult);
void processDevices(AsyncResult &aResult);

UserAuth user_auth(Web_API_KEY, USER_EMAIL, USER_PASS);
FirebaseApp app;

WiFiClientSecure ssl1;
WiFiClientSecure ssl2;
WiFiClientSecure ssl3;

using AsyncClient = AsyncClientClass;
AsyncClient aClient1(ssl1);
AsyncClient aClient2(ssl2);
AsyncClient aClient3(ssl3);

RealtimeDatabase Database;

/* ================= PARSE HELPER ================= */
String jsonGet(const String &json, const String &key) {
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
  String v = json.substring(idx, end);
  v.trim();
  return v;
}

String jsonSub(const String &json, const String &key) {
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
}

/* ================= APPLY HELPERS — CONTROL ================= */
void applyNutrient(const String &j) {
  String v;
  v = jsonGet(j, "mode");
  if (v.length()) nut_mode = v;
  v = jsonGet(j, "isActived");
  if (v.length()) nut_isActived = (v == "true");
  v = jsonGet(j, "tds_min");
  if (v.length()) nut_tdsMin = v.toInt();
  Serial.printf("[NUT] mode=%s isActived=%d tds_min=%d\n",
                nut_mode.c_str(), nut_isActived, nut_tdsMin);
}

void applyPh(const String &j) {
  String v;
  v = jsonGet(j, "mode");
  if (v.length()) ph_mode = v;
  v = jsonGet(j, "isActived");
  if (v.length()) ph_isActived = (v == "true");
  v = jsonGet(j, "ph_min");
  if (v.length()) ph_min = v.toFloat();
  Serial.printf("[PH] mode=%s isActived=%d ph_min=%.2f\n",
                ph_mode.c_str(), ph_isActived, ph_min);
}

void applyWater(const String &j) {
  String v;
  v = jsonGet(j, "mode");
  if (v.length()) wat_mode = v;
  v = jsonGet(j, "isActived");
  if (v.length()) wat_isActived = (v == "true");
  v = jsonGet(j, "duration");
  if (v.length()) wat_duration = (unsigned long)v.toInt();
  v = jsonGet(j, "interval");
  if (v.length()) wat_interval = (unsigned long)v.toInt();
  Serial.printf("[WAT] mode=%s isActived=%d dur=%lu int=%lu\n",
                wat_mode.c_str(), wat_isActived, wat_duration, wat_interval);
}

/* ================= APPLY HELPERS — DEVICES ================= */
void applyTdsCalib(const String &j) {
  String v;
  v = jsonGet(j, "gradien");
  if (v.toFloat() != 0) {
    NUTRIENT_M = v.toFloat();
    Serial.printf("[TDS] M=%.4f\n", NUTRIENT_M);
  }
  v = jsonGet(j, "konstanta");
  if (v.toFloat() != 0) {
    NUTRIENT_C = v.toFloat();
    Serial.printf("[TDS] C=%.4f\n", NUTRIENT_C);
  }
}

void applyPhCalib(const String &j) {
  String v;
  v = jsonGet(j, "gradien");
  if (v.toFloat() != 0) {
    PH_M = v.toFloat();
    Serial.printf("[PHC] M=%.4f\n", PH_M);
  }
  v = jsonGet(j, "konstanta");
  if (v.toFloat() != 0) {
    PH_C = v.toFloat();
    Serial.printf("[PHC] C=%.4f\n", PH_C);
  }
}

/* ================= CALLBACK CONTROL ================= */
void processControl(AsyncResult &aResult) {
  if (!aResult.isResult() || !aResult.available()) return;
  RealtimeDatabaseResult &RTDB = aResult.to<RealtimeDatabaseResult>();

  if (aResult.isError()) {
    Serial.printf("[CTRL ERR] %s (%d)\n",
                  aResult.error().message().c_str(),
                  aResult.error().code());
    return;
  }

  if (!RTDB.isStream()) return;

  String path = RTDB.dataPath().c_str();
  String payload = RTDB.to<String>().c_str();

  if (path == "/" || path == "") {
    String nJson = jsonSub(payload, "nutrient");
    String pJson = jsonSub(payload, "ph");
    String wJson = jsonSub(payload, "water");
    if (nJson.length()) applyNutrient(nJson);
    if (pJson.length()) applyPh(pJson);
    if (wJson.length()) applyWater(wJson);
    Serial.println("[CTRL] Initial snapshot done");
    return;
  }

  if (path == "/nutrient") applyNutrient(payload);
  else if (path == "/nutrient/mode") {
    nut_mode = payload;
  } else if (path == "/nutrient/isActived") {
    nut_isActived = (payload == "true");
  } else if (path == "/nutrient/tds_min") {
    nut_tdsMin = payload.toInt();
  }

  else if (path == "/ph") applyPh(payload);
  else if (path == "/ph/mode") {
    ph_mode = payload;
  } else if (path == "/ph/isActived") {
    ph_isActived = (payload == "true");
  } else if (path == "/ph/ph_min") {
    ph_min = payload.toFloat();
  }

  else if (path == "/water") applyWater(payload);
  else if (path == "/water/mode") {
    wat_mode = payload;
  } else if (path == "/water/isActived") {
    wat_isActived = (payload == "true");
  } else if (path == "/water/duration") {
    wat_duration = (unsigned long)payload.toInt();
  } else if (path == "/water/interval") {
    wat_interval = (unsigned long)payload.toInt();
  }
}

/* ================= HANDLE CALIBRATION ================= */
// Bandingkan float untuk qsort
int compareFloat(const void *a, const void *b) {
  float fa = *(const float *)a;
  float fb = *(const float *)b;
  return (fa > fb) - (fa < fb);
}

void runCalib(CalibBuffer &buf, int pin, const String &fbPath) {
  if (!buf.mode) return;

  // Mulai collecting
  if (!buf.collecting) {
    buf.collecting = true;
    buf.count = 0;
    buf.lastSample = 0;
    Serial.printf("[CALIB] Mulai sampling %s (%d sampel)\n", fbPath.c_str(), CALIB_SAMPLE_COUNT);
  }

  unsigned long now = millis();
  if (now - buf.lastSample < 150) return;  // interval sedikit dipercepat karena sampel lebih banyak
  buf.lastSample = now;

  float v = analogRead(pin) * (VREF / 4095.0f);
  buf.samples[buf.count] = v;
  buf.count++;
  Serial.printf("[CALIB] sample %d/%d: %.4fV\n", buf.count, CALIB_SAMPLE_COUNT, v);

  if (buf.count < CALIB_SAMPLE_COUNT) return;

  // ===== Selesai sampling: buang outlier, hitung trimmed mean =====
  float sorted[CALIB_SAMPLE_COUNT];
  memcpy(sorted, buf.samples, sizeof(sorted));
  qsort(sorted, CALIB_SAMPLE_COUNT, sizeof(float), compareFloat);

  // Buang 20% terendah & 20% tertinggi (masing-masing 6 dari 30 sampel)
  int trim = CALIB_SAMPLE_COUNT * 0.2;
  float sum = 0;
  int used = 0;
  for (int i = trim; i < CALIB_SAMPLE_COUNT - trim; i++) {
    sum += sorted[i];
    used++;
  }
  float avg = sum / used;

  // Sanity check: kalau sebaran data terlalu liar (noise ekstrem), tolak
  float range = sorted[CALIB_SAMPLE_COUNT - 1] - sorted[0];
  bool valid = range < 0.5f;  // sesuaikan threshold sesuai karakteristik sensor kamu

  Serial.printf("[CALIB] Selesai avg(trimmed)=%.4fV range=%.4fV valid=%d → %s\n",
                avg, range, valid, fbPath.c_str());

  object_t json, vTeg, vMode, vValid;
  JsonWriter writer;
  writer.create(vTeg, "tegangan", avg);
  writer.create(vMode, "mode", false);
  writer.create(vValid, "valid", valid);
  writer.join(json, 3, vTeg, vMode, vValid);
  Database.update<object_t>(aClient3, fbPath, json, processDevices, "calibSend");

  buf.mode = false;
  buf.collecting = false;
}

void handleCalibration() {
  if (!configLoaded) return;
  String dp = "/devices/" + esp32Id;
  runCalib(tdsA, TDS_PIN, dp + "/tds/bufferA");
  runCalib(tdsB, TDS_PIN, dp + "/tds/bufferB");
  runCalib(phA, PH_PIN, dp + "/ph/bufferA");
  runCalib(phB, PH_PIN, dp + "/ph/bufferB");
}

/* ================= CALLBACK DEVICES ================= */
void processDevices(AsyncResult &aResult) {
  if (!aResult.isResult() || !aResult.available()) return;
  RealtimeDatabaseResult &RTDB = aResult.to<RealtimeDatabaseResult>();

  if (aResult.isError()) {
    Serial.printf("[DEV ERR] %s (%d)\n",
                  aResult.error().message().c_str(),
                  aResult.error().code());
    return;
  }

  if (!RTDB.isStream()) return;

  String path = RTDB.dataPath().c_str();
  String payload = RTDB.to<String>().c_str();

  // Initial snapshot
  if (path == "/" || path == "") {
    String v = jsonGet(payload, "water_max");
    if (v.length() && v.toFloat() > 0) {
      D_EMPTY = v.toFloat();
      Serial.printf("[DEV] water_max=%.1f\n", D_EMPTY);
    }
    String tdsJson = jsonSub(payload, "tds");
    if (tdsJson.length()) applyTdsCalib(tdsJson);
    String phJson = jsonSub(payload, "ph");
    if (phJson.length()) applyPhCalib(phJson);

    configLoaded = true;
    Serial.println("[DEV] Initial snapshot done");
    return;
  }

  // Sub-object
  if (path == "/tds") applyTdsCalib(payload);
  else if (path == "/ph") applyPhCalib(payload);

  // Field tunggal
  else if (path == "/water_max") {
    D_EMPTY = payload.toFloat();
    Serial.printf("[DEV] water_max=%.1f\n", D_EMPTY);
  }

  else if (path == "/tds/gradien") {
    NUTRIENT_M = payload.toFloat();
    Serial.printf("[TDS] M=%.4f\n", NUTRIENT_M);
  } else if (path == "/tds/konstanta") {
    NUTRIENT_C = payload.toFloat();
    Serial.printf("[TDS] C=%.4f\n", NUTRIENT_C);
  } else if (path == "/tds/bufferA/mode") {
    tdsA.mode = (payload == "true");
    Serial.printf("[TDS] bufferA.mode=%d\n", tdsA.mode);
  } else if (path == "/tds/bufferB/mode") {
    tdsB.mode = (payload == "true");
    Serial.printf("[TDS] bufferB.mode=%d\n", tdsB.mode);
  }

  else if (path == "/ph/gradien") {
    PH_M = payload.toFloat();
    Serial.printf("[PHC] M=%.4f\n", PH_M);
  } else if (path == "/ph/konstanta") {
    PH_C = payload.toFloat();
    Serial.printf("[PHC] C=%.4f\n", PH_C);
  } else if (path == "/ph/bufferA/mode") {
    phA.mode = (payload == "true");
    Serial.printf("[PHC] bufferA.mode=%d\n", phA.mode);
  } else if (path == "/ph/bufferB/mode") {
    phB.mode = (payload == "true");
    Serial.printf("[PHC] bufferB.mode=%d\n", phB.mode);
  }
}

/* ================= SENSOR FUNCTIONS ================= */
void readTdsSampling() {
  static unsigned long sampleTime = 0;
  if (millis() - sampleTime < 40) return;
  sampleTime = millis();
  analogBuffer[analogBufferIndex++] = analogRead(TDS_PIN);
  if (analogBufferIndex >= SCOUNT) analogBufferIndex = 0;
}

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

float readTds() {
  int medianADC = getMedianNum(analogBuffer, SCOUNT);
  float voltage = medianADC * VREF / 4095.0f;
  float tds = (NUTRIENT_M * voltage) + NUTRIENT_C;
  return tds < 0 ? 0 : tds;
}

float readPh() {
  float total = 0;
  for (int i = 0; i < 10; i++) {
    total += analogRead(PH_PIN);
    delay(10);
  }
  float voltage = (total / 10.0f) * VREF / 4095.0f;
  return constrain(PH_M * voltage + PH_C, 0, 14);
}

float readWaterLevel() {
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(5);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);
  long duration = pulseIn(ECHO_PIN, HIGH, 60000);
  if (duration == 0) return -1;
  float dist = duration * 0.0343f / 2.0f;
  if (dist >= D_EMPTY) return 100.0f;
  if (dist <= D_FULL) return 0.0f;
  return (D_EMPTY - dist) * 100.0f / (D_EMPTY - D_FULL);
}

/* ================= HANDLE PUMPS ================= */
void setRelay(int pin, bool on, const char *label) {
  digitalWrite(pin, on ? LOW : HIGH);
  Serial.printf("[RELAY] %s → %s\n", label, on ? "ON" : "OFF");
}

void handleWater() {
  if (!configLoaded) return;

  if (wat_mode == "manual") {
    if (waterRunning != wat_isActived) {
      setRelay(RELAY_WATER, wat_isActived, "Water");
      waterRunning = wat_isActived;
    }
    return;
  }

  // AUTO
  unsigned long now = millis();
  if (!waterRunning && (lastWaterStart == 0 || now - lastWaterStart >= wat_interval)) {
    setRelay(RELAY_WATER, true, "Water AUTO on");
    waterRunning = true;
    lastWaterStart = now;
  }
  if (waterRunning && now - lastWaterStart >= wat_duration) {
    setRelay(RELAY_WATER, false, "Water AUTO off");
    waterRunning = false;
    lastWaterStart = now;
  }
}

void handleNutrient() {
  if (!configLoaded) return;
  unsigned long now = millis();

  if (nut_mode == "manual") {
    if (nutrientRunning != nut_isActived) {
      setRelay(RELAY_NUTRIENT, nut_isActived, "Nutrient");
      setRelay(RELAY_NUTRIENT2, nut_isActived, "Nutrient2");
      nutrientRunning = nut_isActived;
    }
    return;
  }

  // AUTO — on jika TDS kurang, off setelah duration, tunggu interval sebelum on lagi
  float tds = readTds();
  if (!nutrientRunning && tds < nut_tdsMin && (lastNutrientStart == 0 || now - lastNutrientStart >= nut_interval)) {
    setRelay(RELAY_NUTRIENT, true, "Nutrient AUTO on");
        setRelay(RELAY_NUTRIENT2, true, "Nutrient2 AUTO on");
    nutrientRunning = true;
    lastNutrientStart = now;
  }
  if (nutrientRunning && now - lastNutrientStart >= nut_duration) {
    setRelay(RELAY_NUTRIENT, false, "Nutrient AUTO off");
        setRelay(RELAY_NUTRIENT2, false, "Nutrient2 AUTO off");
    nutrientRunning = false;
    lastNutrientStart = now;
  }
}

void handlePh() {
  if (!configLoaded) return;
  unsigned long now = millis();

  if (ph_mode == "manual") {
    if (phRunning != ph_isActived) {
      setRelay(RELAY_PH, ph_isActived, "PH");
      phRunning = ph_isActived;
    }
    return;
  }

  // AUTO — on jika pH kurang, off setelah duration, tunggu interval sebelum on lagi
  float ph = readPh();
  if (!phRunning && ph < ph_min && (lastPhStart == 0 || now - lastPhStart >= ph_interval)) {
    setRelay(RELAY_PH, true, "PH AUTO on");
    phRunning = true;
    lastPhStart = now;
  }
  if (phRunning && now - lastPhStart >= ph_duration) {
    setRelay(RELAY_PH, false, "PH AUTO off");
    phRunning = false;
    lastPhStart = now;
  }
}

/* ================= SETUP ================= */
void setup() {
  Serial.begin(115200);
  delay(1000);
  Serial.println("Booting..");

  pinMode(RELAY_PH, OUTPUT);
  digitalWrite(RELAY_PH, HIGH);
  pinMode(RELAY_WATER, OUTPUT);
  digitalWrite(RELAY_WATER, HIGH);
  pinMode(RELAY_NUTRIENT, OUTPUT);
  digitalWrite(RELAY_NUTRIENT, HIGH);
  pinMode(RELAY_NUTRIENT2, OUTPUT);
  digitalWrite(RELAY_NUTRIENT2, HIGH);
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

  ssl1.setInsecure();
  ssl1.setConnectionTimeout(1000);
  ssl1.setHandshakeTimeout(5);
  ssl2.setInsecure();
  ssl2.setConnectionTimeout(1000);
  ssl2.setHandshakeTimeout(5);
  ssl3.setInsecure();
  ssl3.setConnectionTimeout(1000);
  ssl3.setHandshakeTimeout(5);

  initializeApp(aClient1, app, getAuth(user_auth), processControl, "authTask");
  app.getApp<RealtimeDatabase>(Database);
  Database.url(DATABASE_URL);
}

/* ================= LOOP ================= */
void loop() {
  app.loop();
  readTdsSampling();

  if (app.ready() && !streamStarted) {
    streamStarted = true;
    Database.get(aClient1, "/control/" + esp32Id, processControl, true, "controlStream");
    Database.get(aClient2, "/devices/" + esp32Id, processDevices, true, "deviceStream");
    Serial.println("[BOOT] Stream started");
  }

  // Kirim last_seen tiap 30 detik
  if (app.ready() && configLoaded && millis() - lastSeenSend >= LAST_SEEN_INTERVAL) {
    lastSeenSend = millis();
    int64_t ts = (int64_t)(time(nullptr) * 1000LL);
    Database.set<int64_t>(aClient3, "/devices/" + esp32Id + "/last_seen", ts, processDevices, "lastSeen");
    Serial.printf("[DEV] last_seen=%lld\n", ts);
  }

  handleWater();
  handleNutrient();
  handlePh();

  handleCalibration();

  // Kirim sensor tiap 5 detik ← tambah ini
  if (app.ready() && configLoaded && millis() - lastSensorSend >= SENSOR_INTERVAL) {
    lastSensorSend = millis();

    float ph = readPh();
    float tds = readTds();
    float waterLevel = readWaterLevel();

    object_t json, vPh, vTds, vWl;
    JsonWriter writer;
    writer.create(vPh, "ph", ph);
    writer.create(vTds, "tds", tds);
    writer.create(vWl, "water_level", waterLevel);
    writer.join(json, 3, vPh, vTds, vWl);

    Database.set<object_t>(aClient3, "/sensor_data/" + esp32Id, json, processDevices, "sensorSend");
    Serial.printf("[SENSOR] ph=%.2f tds=%.2f wl=%.2f\n", ph, tds, waterLevel);
  }
}