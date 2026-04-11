#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include <time.h>
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"

/* ================= WIFI & FIREBASE ================= */
#define WIFI_SSID "WASIS FAMILY"
#define WIFI_PASSWORD "01021969"
// #define WIFI_SSID "Aku Siapa"
// #define WIFI_PASSWORD "Hehehehehehe"
#define DATABASE_URL "https://smart-hydroponic-14bcf-default-rtdb.asia-southeast1.firebasedatabase.app"
#define API_KEY "AIzaSyCIhqKK-UMKd_Jmw4WGEWojye8P_zNBOro"

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
const float PH_M = -19.35;
const float PH_C = 32.13;
float D_FULL = 1.0;    // Jarak saat air penuh (cm)
float D_EMPTY = 20.0;  // Nilai default jika firebase belum terbaca

/* ================= GLOBAL VARIABLES ================= */
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

String esp32Id;
unsigned long lastSend = 0;
int analogBuffer[SCOUNT];
int analogBufferIndex = 0;

// Water Pompa Variables
unsigned long lastWaterPumpStart = 0;
unsigned long waterPumpInterval = 300000;
unsigned long waterPumpDuration = 10000;
bool waterPumpRunning = false;

// Nutrient Pompa Variables
unsigned long lastNutPumpStart = 0;
unsigned long nutPumpInterval = 10000;
unsigned long nutPumpDuration = 500;
int nutTDSMax = 1000;
int nutTDSMin = 400;
bool nutPumpRunning = false;

/* ================= PH POMPA VARIABLES ================= */
unsigned long lastPhPumpStart = 0;
unsigned long phPumpInterval = 10000;
unsigned long phPumpDuration = 500;
float phMin = 6.0;  // pH minimum (default)
bool phPumpRunning = false;


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
  float tds = (-376.013 * voltage) + 1075.246;  // Kalibrasi kamu
  return (tds < 0) ? 0 : tds;
}

float readPhValue() {
  float total = 0;
  for (int i = 0; i < 10; i++) {
    total += analogRead(PH_PIN);
    delay(10);
  }
  float voltage = (total / 10.0) * VREF / 4095.0;
  float ph = PH_M * voltage + PH_C;  // Kalibrasi kamu
  return constrain(ph, 0, 14);
}

float readDistanceCm() {
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);
  long duration = pulseIn(ECHO_PIN, HIGH, 30000);
  return (duration == 0) ? -1 : duration / 58.0;
}

/* ================== CORE LOGIC ================= */

void handleWaterPump() {
  String path = "/control/" + esp32Id + "/water";

  bool okMode = Firebase.RTDB.getString(&fbdo, path + "/mode");
  String mode = fbdo.stringData();

  bool okActive = Firebase.RTDB.getBool(&fbdo, path + "/isActived");
  bool isActived = fbdo.boolData();

  bool okInterval = Firebase.RTDB.getInt(&fbdo, path + "/interval");
  if (okInterval) waterPumpInterval = fbdo.intData();

  bool okDuration = Firebase.RTDB.getInt(&fbdo, path + "/duration");
  if (okDuration) waterPumpDuration = fbdo.intData();

  unsigned long now = millis();

  /* ================= FAIL SAFE ================= */
  if (!okMode || !okActive) {
    Serial.println("WATER: Firebase ERROR → FORCE OFF");
    digitalWrite(RELAY_WATER, HIGH);
    waterPumpRunning = false;
    return;
  }

  if (mode == "auto") {
    if (!waterPumpRunning && (now - lastWaterPumpStart >= waterPumpInterval || lastWaterPumpStart == 0)) {
      digitalWrite(RELAY_WATER, LOW);
      waterPumpRunning = true;
      lastWaterPumpStart = now;
      Serial.println("WATER PUMP: Auto ON");
    }
    if (waterPumpRunning && (now - lastWaterPumpStart >= waterPumpDuration)) {
      digitalWrite(RELAY_WATER, HIGH);
      waterPumpRunning = false;
      lastWaterPumpStart = now;  // Reset interval dari titik mati
      Serial.println("WATER PUMP: Auto OFF");
    }
  } else {  // Manual
    digitalWrite(RELAY_WATER, isActived ? LOW : HIGH);
    waterPumpRunning = isActived;
    return;
  }
}

void handleNutrientPump() {
  String path = "/control/" + esp32Id + "/nutrient";

  bool okMode = Firebase.RTDB.getString(&fbdo, path + "/mode");
  String mode = fbdo.stringData();

  bool okActive = Firebase.RTDB.getBool(&fbdo, path + "/isActived");
  bool isActived = fbdo.boolData();

  bool okTDSMin = Firebase.RTDB.getInt(&fbdo, path + "/tds_min");
  if (okTDSMin) nutTDSMin = fbdo.intData();

  bool okTDSMax = Firebase.RTDB.getInt(&fbdo, path + "/tds_max");
  if (okTDSMax) nutTDSMax = fbdo.intData();

  float tds = readTdsValue();
  unsigned long now = millis();

  // ===== FAIL SAFE =====
  if (!okMode || !okActive) {
    Serial.println("NUTRIENT: Firebase ERROR → FORCE OFF");
    digitalWrite(RELAY_NUTRIENT, HIGH);
    nutPumpRunning = false;
    return;
  }

  if (mode == "manual") {

    // if (isActived) {
    //   if (!nutPumpRunning && (now - lastNutPumpStart >= nutPumpInterval || lastNutPumpStart == 0)) {
    //     digitalWrite(RELAY_NUTRIENT, LOW);
    //     nutPumpRunning = true;
    //     lastNutPumpStart = now;
    //   }

    //   if (nutPumpRunning && now - lastNutPumpStart >= nutPumpDuration) {
    //     digitalWrite(RELAY_NUTRIENT, HIGH);
    //     nutPumpRunning = false;
    //     lastNutPumpStart = now;
    //   }

    // } else {
    //   digitalWrite(RELAY_NUTRIENT, HIGH);
    //   nutPumpRunning = false;
    //   lastNutPumpStart = now;
    // }

    digitalWrite(RELAY_NUTRIENT, isActived ? LOW : HIGH);
    nutPumpRunning = isActived;

    return;
  }

  // AUTO
  if (tds < nutTDSMin) {
    if (!nutPumpRunning && (now - lastNutPumpStart >= nutPumpInterval || lastNutPumpStart == 0)) {
      digitalWrite(RELAY_NUTRIENT, LOW);
      nutPumpRunning = true;
      lastNutPumpStart = now;
    }

    if (nutPumpRunning && now - lastNutPumpStart >= nutPumpDuration) {
      digitalWrite(RELAY_NUTRIENT, HIGH);
      nutPumpRunning = false;
      lastNutPumpStart = now;
    }

  } else {
    digitalWrite(RELAY_NUTRIENT, HIGH);
    nutPumpRunning = false;
  }
}

void handlePhPump() {
  String path = "/control/" + esp32Id + "/ph";

  bool okMode = Firebase.RTDB.getString(&fbdo, path + "/mode");
  String mode = fbdo.stringData();

  bool okActive = Firebase.RTDB.getBool(&fbdo, path + "/isActived");
  bool isActived = fbdo.boolData();

  bool okPhMin = Firebase.RTDB.getFloat(&fbdo, path + "/ph_min");
  if (okPhMin) phMin = fbdo.floatData();

  float ph = readPhValue();
  unsigned long now = millis();

  // ===== FAIL SAFE =====
  if (!okMode || !okActive) {
    Serial.println("PH: Firebase ERROR → FORCE OFF");
    digitalWrite(RELAY_PH, HIGH);
    phPumpRunning = false;
    return;
  }

  if (mode == "manual") {
    digitalWrite(RELAY_PH, isActived ? LOW : HIGH);
    phPumpRunning = isActived;
    return;
  }

  // AUTO — nyala jika pH di bawah threshold min
  if (ph < phMin) {
    if (!phPumpRunning && (now - lastPhPumpStart >= phPumpInterval || lastPhPumpStart == 0)) {
      digitalWrite(RELAY_PH, LOW);
      phPumpRunning = true;
      lastPhPumpStart = now;
      Serial.println("PH PUMP: Auto ON");
    }

    if (phPumpRunning && (now - lastPhPumpStart >= phPumpDuration)) {
      digitalWrite(RELAY_PH, HIGH);
      phPumpRunning = false;
      lastPhPumpStart = now;
      Serial.println("PH PUMP: Auto OFF");
    }

  } else {
    digitalWrite(RELAY_PH, HIGH);
    phPumpRunning = false;
  }
}

void setup() {
  Serial.begin(115200);
  pinMode(RELAY_PH, OUTPUT);
  pinMode(RELAY_WATER, OUTPUT);
  pinMode(RELAY_NUTRIENT, OUTPUT);
  digitalWrite(RELAY_PH, HIGH);
  digitalWrite(RELAY_WATER, HIGH);
  digitalWrite(RELAY_NUTRIENT, HIGH);
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi Connected");

  auth.user.email = "zerxonin@gmail.com";
  auth.user.password = "123456";
  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;
  config.token_status_callback = tokenStatusCallback;
  Firebase.begin(&config, &auth);
  fbdo.setBSSLBufferSize(4096, 1024);
  Firebase.reconnectWiFi(true);
  Serial.println("Firebase Connected");

  esp32Id = WiFi.macAddress();
  esp32Id.replace(":", "");
  Serial.print("ESP32 ID: ");
  Serial.println(esp32Id);
}

void loop() {
  readTdsSampling();

  // Kontrol Pompa
  handleWaterPump();
  handleNutrientPump();
  handlePhPump();

  // Jalankan setiap 5 detik
  if (Firebase.ready() && (millis() - lastSend > 5000)) {
    lastSend = millis();

    // 1. Ambil ambang batas air dari Firebase (agar dinamis)
    if (Firebase.RTDB.getFloat(&fbdo, "/devices/" + esp32Id + "/water_max")) {
      D_EMPTY = fbdo.floatData();
    }

    // 2. Baca Sensor
    float ph = readPhValue();
    float tds = readTdsValue();
    float dist = readDistanceCm();
    float waterLevel = (dist > 0) ? constrain((D_EMPTY - dist) / (D_EMPTY - D_FULL) * 100.0, 0, 100) : 0;

    // 3. Kirim Data
    FirebaseJson json;
    json.set("ph", ph);
    json.set("tds", tds);
    json.set("water_level", waterLevel);
    json.set("updated_at", millis());
    Firebase.RTDB.setJSON(&fbdo, ("/sensor_data/" + esp32Id).c_str(), &json);

    // 4. Update Status
    Firebase.RTDB.setInt(&fbdo, ("/devices/" + esp32Id + "/last_seen").c_str(), (long)time(nullptr) * 1000);

    Serial.printf("WL: %.1f%% | pH: %.2f | TDS: %.0f ppm | Water: %s | Nutrient: %s | PH: %s\n",
                  waterLevel, ph, tds,
                  waterPumpRunning ? "ON" : "OFF",
                  nutPumpRunning ? "ON" : "OFF",
                  phPumpRunning ? "ON" : "OFF");
  }
}