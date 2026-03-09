#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include <time.h>

/* ================= WIFI & FIREBASE ================= */
#define WIFI_SSID "WASIS FAMILY"
#define WIFI_PASSWORD "01021969"
#define DATABASE_URL "https://smart-hydroponic-14bcf-default-rtdb.asia-southeast1.firebasedatabase.app"
#define API_KEY "AIzaSyApu6dcDvBa2RsSkqjAEg_uomsx4zA61PY"

/* ================= PIN DEFINITION ================= */
#define RELAY_NUTRISI 26
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

// Pompa Variables
unsigned long lastPumpStart = 0;
unsigned long pumpInterval = 300000;
unsigned long pumpDuration = 10000;
bool pumpRunning = false;

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

void handlePump() {
  // Ambil pengaturan dari Firebase
  String path = "/control/" + esp32Id + "/water";
  String mode = "auto";
  bool isActived = false;

  if (Firebase.RTDB.getString(&fbdo, path + "/mode")) mode = fbdo.stringData();
  if (Firebase.RTDB.getBool(&fbdo, path + "/isActived")) isActived = fbdo.boolData();
  if (Firebase.RTDB.getInt(&fbdo, path + "/interval")) pumpInterval = fbdo.intData();
  if (Firebase.RTDB.getInt(&fbdo, path + "/duration")) pumpDuration = fbdo.intData();

  unsigned long now = millis();

  if (mode == "auto") {
    if (!pumpRunning && (now - lastPumpStart >= pumpInterval || lastPumpStart == 0)) {
      digitalWrite(RELAY_WATER, LOW);
      pumpRunning = true;
      lastPumpStart = now;
      Serial.println("PUMP: Auto ON");
    }
    if (pumpRunning && (now - lastPumpStart >= pumpDuration)) {
      digitalWrite(RELAY_WATER, HIGH);
      pumpRunning = false;
      lastPumpStart = now;  // Reset interval dari titik mati
      Serial.println("PUMP: Auto OFF");
    }
  } else {  // Manual
    digitalWrite(RELAY_WATER, isActived ? LOW : HIGH);
    pumpRunning = isActived;
  }
}

void setup() {
  Serial.begin(115200);
  pinMode(RELAY_WATER, OUTPUT);
  pinMode(RELAY_NUTRISI, OUTPUT);
  digitalWrite(RELAY_WATER, HIGH);
  digitalWrite(RELAY_NUTRISI, HIGH);
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nWiFi Connected");

  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;
  Firebase.signUp(&config, &auth, "", "");
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  esp32Id = WiFi.macAddress();
  esp32Id.replace(":", "");
}

void loop() {
  readTdsSampling();

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
    Firebase.RTDB.setInt(&fbdo, ("/devices/" + esp32Id + "/last_seen").c_str(), millis());

    // 5. Kontrol Pompa
    handlePump();

    Serial.printf("WL: %.1f%% | pH: %.2f | TDS: %.0f ppm | Pump: %s\n",
                  waterLevel, ph, tds, pumpRunning ? "ON" : "OFF");
  }
}