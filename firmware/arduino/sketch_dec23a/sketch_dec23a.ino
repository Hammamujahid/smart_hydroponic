#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include <time.h>

/* ================= WIFI & FIREBASE ================= */
#define WIFI_SSID "WASIS FAMILY"
#define WIFI_PASSWORD "01021969"

// #define WIFI_SSID "Aku Siapa"
// #define WIFI_PASSWORD "Hehehehehehe"

#define DATABASE_URL "https://smart-hydroponic-14bcf-default-rtdb.asia-southeast1.firebasedatabase.app"
#define API_KEY "AIzaSyApu6dcDvBa2RsSkqjAEg_uomsx4zA61PY"

/* ================= RELAY ================= */
#define RELAY_NUTRISI 26
#define RELAY_WATER 27

/* ================= ULTRASONIC ================= */
#define TRIG_PIN 19
#define ECHO_PIN 18

/* ================= TDS ================= */
#define TDS_PIN 35
#define VREF 3.3
#define SCOUNT 30
#define TDS_CALIBRATION_FACTOR 0.18

/* ================= PH ================= */
#define PH_PIN 34

// Hasil kalibrasi pH kamu
const float PH_M = -19.35;
const float PH_C = 32.13;

/* ================= FIREBASE OBJECT ================= */
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

/* ================= GLOBAL ================= */
String esp32Id;
unsigned long lastSend = 0;

/* ================= ULTRASONIC CALIB ================= */
float D_FULL = 1.0;  // cm

/* ================= TDS BUFFER ================= */
int analogBuffer[SCOUNT];
int analogBufferIndex = 0;
float temperature = 26.0;

/* ================= WATER PUMP ================= */
unsigned long lastPumpStart = 0;
unsigned long pumpInterval = 300000;  // 5 menit
unsigned long pumpDuration = 10000;   // 10 detik

bool pumpRunning = false;

/* ================================================= */
/* ================== MEDIAN FILTER ================= */
int getMedianNum(int bArray[], int len) {
  int bTab[len];
  memcpy(bTab, bArray, len * sizeof(int));

  for (int j = 0; j < len - 1; j++) {
    for (int i = 0; i < len - j - 1; i++) {
      if (bTab[i] > bTab[i + 1]) {
        int tmp = bTab[i];
        bTab[i] = bTab[i + 1];
        bTab[i + 1] = tmp;
      }
    }
  }

  return (len % 2 == 1)
           ? bTab[len / 2]
           : (bTab[len / 2] + bTab[len / 2 - 1]) / 2;
}

/* ================================================= */
/* ===================== SETUP ===================== */
void setup() {
  Serial.begin(115200);

  pinMode(RELAY_WATER, OUTPUT);
  pinMode(RELAY_NUTRISI, OUTPUT);
  digitalWrite(RELAY_WATER, HIGH);
  digitalWrite(RELAY_NUTRISI, HIGH);

  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
  pinMode(TDS_PIN, INPUT);
  pinMode(PH_PIN, INPUT);

  /* ===== WIFI ===== */
  Serial.print("Connecting to WiFi");
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi Connected");

  /* ===== TIME SYNC (SSL) ===== */
  configTime(0, 0, "pool.ntp.org", "time.nist.gov");
  Serial.print("Syncing time");
  time_t now = time(nullptr);
  while (now < 100000) {
    delay(500);
    Serial.print(".");
    now = time(nullptr);
  }
  Serial.println("\nTime synced");

  /* ===== ESP32 ID ===== */
  esp32Id = WiFi.macAddress();
  esp32Id.replace(":", "");
  Serial.print("ESP32 ID: ");
  Serial.println(esp32Id);

  /* ===== FIREBASE ===== */
  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;
  delay(2000);

  Firebase.signUp(&config, &auth, "", "");
  Firebase.reconnectWiFi(true);
  fbdo.setBSSLBufferSize(4096, 1024);
  Firebase.begin(&config, &auth);

  Serial.println("Firebase Connected");
}

/* ================================================= */
/* ====================== LOOP ===================== */
void loop() {
  readTdsSampling();

  if (Firebase.ready() && millis() - lastSend > 5000) {
    lastSend = millis();
    sendSensorData();
    updateDeviceStatus();
    controlPump();
  }
}

/* ================================================= */
/* ================= ULTRASONIC ==================== */
float readDistanceCm() {
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);

  long duration = pulseIn(ECHO_PIN, HIGH, 30000);

  if (duration == 0) return -1;
  return duration / 58.0;
}

float readWaterLevelPercent() {
  float total = 0;
  int valid = 0;
  float D_EMPTY = 0;
  String path = "/devices/" + esp32Id + "/water_max";

  if (Firebase.RTDB.getFloat(&fbdo, path)) {
    D_EMPTY = fbdo.floatData();
  } else {
    Serial.println(fbdo.errorReason());
  }

  for (int i = 0; i < 5; i++) {
    float d = readDistanceCm();
    if (d > 0) {
      total += d;
      valid++;
    }
    delay(50);
  }

  if (valid == 0) return -1;

  float avg = total / valid;
  float percent = (D_EMPTY - avg) / (D_EMPTY - D_FULL) * 100.0;
  return constrain(percent, 0, 100);
}

/* ================================================= */
/* ===================== TDS ======================= */
void readTdsSampling() {
  static unsigned long sampleTime = 0;

  if (millis() - sampleTime > 40) {  // sampling tiap 40ms
    sampleTime = millis();
    analogBuffer[analogBufferIndex] = analogRead(TDS_PIN);
    analogBufferIndex++;
    if (analogBufferIndex >= SCOUNT) {
      analogBufferIndex = 0;
    }
  }
}


float readTdsValue() {
  int medianADC = getMedianNum(analogBuffer, SCOUNT);
  float voltage = medianADC * VREF / 4095.0;

  // ===== Regresi Linear Hasil Kalibrasi Kamu =====
  float tds = (-376.013 * voltage) + 1075.246;

  // Hindari nilai negatif
  if (tds < 0) tds = 0;

  return tds;
}


/* ================================================= */
/* ====================== PH ======================= */
float readPhValue() {
  float total = 0;

  for (int i = 0; i < 10; i++) {
    total += analogRead(PH_PIN);
    delay(10);
  }

  float adcAvg = total / 10.0;
  float voltage = adcAvg * VREF / 4095.0;
  float ph = PH_M * voltage + PH_C;

  return constrain(ph, 0, 14);
}

/* ================================================= */
/* ================= SEND DATA ===================== */
void sendSensorData() {
  float ph = readPhValue();
  float tds = readTdsValue();
  float waterLevel = readWaterLevelPercent();

  Serial.printf(
    "WL: %.1f%% | pH: %.2f | TDS: %.0f ppm\n",
    waterLevel, ph, tds);

  String path = "/sensor_data/" + esp32Id;
  FirebaseJson json;
  json.set("ph", ph);
  json.set("tds", tds);
  json.set("water_level", waterLevel);
  json.set("updated_at", millis());

  Firebase.RTDB.setJSON(&fbdo, path.c_str(), &json);
}

/* ================================================= */
/* ================= DEVICE STATUS ================= */
void updateDeviceStatus() {
  String path = "/devices/" + esp32Id;
  FirebaseJson json;
  json.set("last_seen", millis());
  Firebase.RTDB.updateNode(&fbdo, path.c_str(), &json);
}

/* ================================================= */
/* ================= WATER PUMP ================= */
void runAutoPump() {

  unsigned long now = millis();

  /* ===== jika pompa sedang mati ===== */
  if (!pumpRunning && (now - lastPumpStart >= pumpInterval)) {

    Serial.println("AUTO PUMP START");

    digitalWrite(RELAY_WATER, LOW);  // relay aktif
    pumpRunning = true;
    lastPumpStart = now;
  }

  /* ===== jika pompa sedang nyala ===== */
  if (pumpRunning && (now - lastPumpStart >= pumpDuration)) {

    Serial.println("AUTO PUMP STOP");

    digitalWrite(RELAY_WATER, HIGH);
    pumpRunning = false;
    lastPumpStart = now;
  }
}

bool controlWater() {

  String path = "/control/" + esp32Id + "/water";

  String pathMode = path + "/mode";
  String pathIsActived = path + "/isActived";
  String pathInterval = path + "/interval";
  String pathDuration = path + "/duration";

  String mode = "auto";
  bool isActived = false;

  if (Firebase.RTDB.getString(&fbdo, pathMode)) {
    mode = fbdo.stringData();
  } else {
    Serial.println(fbdo.errorReason());
  }

  if (Firebase.RTDB.getBool(&fbdo, pathIsActived)) {
    isActived = fbdo.boolData();
  }

  if (Firebase.RTDB.getInt(&fbdo, pathInterval)) {
    pumpInterval = fbdo.intData();
  }

  if (Firebase.RTDB.getInt(&fbdo, pathDuration)) {
    pumpDuration = fbdo.intData();
  }

  if (mode == "auto") {
    runAutoPump();
  }

  else if (mode == "manual") {

    if (isActived) {
      digitalWrite(RELAY_WATER, LOW);
      pumpRunning = true;
    } else {
      digitalWrite(RELAY_WATER, HIGH);
      pumpRunning = false;
    }
  }

  return pumpRunning;
}

/* ================================================= */
/* ================= CONTROL PUMP ================= */
void controlPump() {

  bool waterPump = controlWater();

  if (waterPump) {
    Serial.println("Pump ON");
  } else {
    Serial.println("Pump OFF");
  }
}