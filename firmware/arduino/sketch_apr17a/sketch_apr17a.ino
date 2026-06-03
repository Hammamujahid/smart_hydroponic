#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include <time.h>
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"

/* ================= WIFI & FIREBASE ================= */
#define WIFI_SSID "WASIS FAMILY"
#define WIFI_PASSWORD "01021969"
#define DATABASE_URL "https://smart-hydroponic-14bcf-default-rtdb.asia-southeast1.firebasedatabase.app"
#define API_KEY "AIzaSyCIhqKK-UMKd_Jmw4WGEWojye8P_zNBOro"

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
FirebaseData fbdo;      // Untuk kirim sensor data
FirebaseData fbdoCtrl;  // Khusus untuk poll kontrol pompaFirebaseAuth auth;
FirebaseAuth auth;
FirebaseConfig config;
String esp32Id;

/* ================= TIMING ================= */
unsigned long lastSend             = 0;
unsigned long lastFirebasePoll     = 0;
const unsigned long FIREBASE_POLL_INTERVAL = 200; // Lebih responsif

/* ================= TDS BUFFER ================= */
int analogBuffer[SCOUNT];
int analogBufferIndex = 0;

/* ================= CACHED STATE ================= */
struct PumpState {
  String mode      = "manual";
  bool   isActived = false;
  bool   prevActived = false; // Untuk deteksi perubahan isActived
  int    failCount = 0;
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
unsigned long nutPumpInterval  = 300000; // Jeda antar dosis auto (5 menit)
unsigned long nutPumpDuration  = 500;    // Nyala hanya 500ms per dosis
int           nutTDSMin        = 400;
int           nutTDSMax        = 1000;
unsigned long lastNutPumpStart = 0;
bool          nutPumpRunning   = false;

/* ================= PH PUMP CONFIG ================= */
unsigned long phPumpInterval  = 300000; // Jeda antar dosis auto (5 menit)
unsigned long phPumpDuration  = 500;    // Nyala hanya 500ms per dosis
float         phMin           = 6.0;
unsigned long lastPhPumpStart = 0;
bool          phPumpRunning   = false;

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
   POLL FIREBASE — getJSON: 1 request per pompa,
   jauh lebih cepat dari baca field satu-satu
   ================================================= */
void pollFirebase() {
  if (!Firebase.ready()) return;

  // -------- WATER --------
  if (Firebase.RTDB.getJSON(&fbdoCtrl, "/control/" + esp32Id + "/water")) {
    FirebaseJson &json = fbdoCtrl.jsonObject();
    FirebaseJsonData result;

    if (json.get(result, "mode"))      waterState.mode      = result.stringValue;
    if (json.get(result, "isActived")) waterState.isActived = result.boolValue;
    if (json.get(result, "interval"))  waterPumpInterval    = (unsigned long)result.intValue;
    if (json.get(result, "duration"))  waterPumpDuration    = (unsigned long)result.intValue;

    waterState.failCount = 0;
  } else {
    waterState.failCount++;
    Serial.printf("[POLL] Water fail #%d: %s\n", waterState.failCount, fbdoCtrl.errorReason().c_str());
  }

  // -------- NUTRIENT --------
  if (Firebase.RTDB.getJSON(&fbdoCtrl, "/control/" + esp32Id + "/nutrient")) {
    FirebaseJson &json = fbdoCtrl.jsonObject();
    FirebaseJsonData result;

    bool newActived = nutrientState.isActived;
    if (json.get(result, "mode"))      nutrientState.mode = result.stringValue;
    if (json.get(result, "isActived")) newActived         = result.boolValue;
    if (json.get(result, "tds_min"))   nutTDSMin          = result.intValue;
    if (json.get(result, "tds_max"))   nutTDSMax          = result.intValue;
    if (json.get(result, "interval"))  nutPumpInterval    = (unsigned long)result.intValue;
    if (json.get(result, "duration"))  nutPumpDuration    = (unsigned long)result.intValue;

    nutrientState.prevActived = nutrientState.isActived;
    nutrientState.isActived   = newActived;
    nutrientState.failCount   = 0;
  } else {
    nutrientState.failCount++;
    Serial.printf("[POLL] Nutrient fail #%d: %s\n", nutrientState.failCount, fbdoCtrl.errorReason().c_str());
  }

  // -------- PH --------
  if (Firebase.RTDB.getJSON(&fbdoCtrl, "/control/" + esp32Id + "/ph")) {
    FirebaseJson &json = fbdoCtrl.jsonObject();
    FirebaseJsonData result;

    bool newActived = phState.isActived;
    if (json.get(result, "mode"))      phState.mode    = result.stringValue;
    if (json.get(result, "isActived")) newActived      = result.boolValue;
    if (json.get(result, "ph_min"))    phMin           = result.floatValue;
    if (json.get(result, "interval"))  phPumpInterval  = (unsigned long)result.intValue;
    if (json.get(result, "duration"))  phPumpDuration  = (unsigned long)result.intValue;

    phState.prevActived = phState.isActived;
    phState.isActived   = newActived;
    phState.failCount   = 0;
  } else {
    phState.failCount++;
    Serial.printf("[POLL] PH fail #%d: %s\n", phState.failCount, fbdoCtrl.errorReason().c_str());
  }
}

/* =================================================
   HANDLE WATER PUMP
   Mode auto  : nyala interval/duration seperti biasa
   Mode manual: ikuti isActived langsung (on/off bebas)
   ================================================= */
void handleWaterPump() {
  unsigned long now = millis();

  if (waterState.failCount >= 3) {
    Serial.println("[FAILSAFE] Water → FORCE OFF");
    setRelay(RELAY_WATER, false, "Water");
    waterPumpRunning = false;
    return;
  }

  if (waterState.mode == "auto") {
    if (!waterPumpRunning && (lastWaterPumpStart == 0 || now - lastWaterPumpStart >= waterPumpInterval)) {
      setRelay(RELAY_WATER, true, "Water AUTO on");
      waterPumpRunning   = true;
      lastWaterPumpStart = now;
    }
    if (waterPumpRunning && (now - lastWaterPumpStart >= waterPumpDuration)) {
      setRelay(RELAY_WATER, false, "Water AUTO off");
      waterPumpRunning   = false;
      lastWaterPumpStart = now;
    }
  } else {
    // Manual: on/off langsung tanpa pembatasan durasi
    bool target = waterState.isActived;
    if (waterPumpRunning != target) {
      setRelay(RELAY_WATER, target, "Water MANUAL");
      waterPumpRunning = target;
    }
  }
}

/* =================================================
   HANDLE NUTRIENT PUMP
   Prinsip utama: relay TIDAK PERNAH nyala terus-menerus.
   Selalu hanya nyala selama nutPumpDuration (ms) lalu mati.

   Mode manual : isActived false→true = trigger 1 dosis
                 isActived true→false = batalkan jika sedang nyala
   Mode auto   : trigger dosis tiap nutPumpInterval
                 selama TDS masih di bawah minimum
   ================================================= */
void handleNutrientPump() {
  unsigned long now = millis();

  // FAILSAFE
  if (nutrientState.failCount >= 3) {
    if (nutPumpRunning) {
      setRelay(RELAY_NUTRIENT, false, "Nutrient FAILSAFE");
      nutPumpRunning = false;
    }
    return;
  }

  // Auto-off setelah durasi habis — berlaku semua mode
  if (nutPumpRunning && (now - lastNutPumpStart >= nutPumpDuration)) {
    setRelay(RELAY_NUTRIENT, false, "Nutrient tetes selesai");
    nutPumpRunning   = false;
    lastNutPumpStart = now; // Mulai hitung interval dari sini
  }

  // -------- MANUAL --------
  if (nutrientState.mode == "manual") {
    // Rising edge = trigger 1 tetes
    if (!nutrientState.prevActived && nutrientState.isActived && !nutPumpRunning) {
      setRelay(RELAY_NUTRIENT, true, "Nutrient MANUAL tetes");
      nutPumpRunning   = true;
      lastNutPumpStart = now;
    }
    return;
  }

  // -------- AUTO --------
  float tds = readTdsValue();
  Serial.printf("[NUT AUTO] TDS:%.0f min:%d running:%s elapsed:%lus\n",
    tds, nutTDSMin, nutPumpRunning ? "Y" : "N",
    (now - lastNutPumpStart) / 1000);

  if (tds < nutTDSMin) {
    // Belum cukup → tetes berkala setiap interval
    if (!nutPumpRunning && (lastNutPumpStart == 0 || now - lastNutPumpStart >= nutPumpInterval)) {
      setRelay(RELAY_NUTRIENT, true, "Nutrient AUTO tetes");
      nutPumpRunning   = true;
      lastNutPumpStart = now;
    }
  } else {
    // Sudah cukup → pastikan mati, reset timer
    if (nutPumpRunning) {
      setRelay(RELAY_NUTRIENT, false, "Nutrient AUTO stop (TDS OK)");
      nutPumpRunning = false;
    }
    lastNutPumpStart = now; // Reset agar tidak langsung tetes saat turun lagi
  }
}

/* =================================================
   HANDLE PH PUMP
   Sama persis dengan nutrient pump, tapi untuk pH.
   ================================================= */
void handlePhPump() {
  unsigned long now = millis();

  // FAILSAFE
  if (phState.failCount >= 3) {
    if (phPumpRunning) {
      setRelay(RELAY_PH, false, "PH FAILSAFE");
      phPumpRunning = false;
    }
    return;
  }

  // Auto-off setelah durasi habis — berlaku semua mode
  if (phPumpRunning && (now - lastPhPumpStart >= phPumpDuration)) {
    setRelay(RELAY_PH, false, "PH tetes selesai");
    phPumpRunning   = false;
    lastPhPumpStart = now;
  }

  // -------- MANUAL --------
  if (phState.mode == "manual") {
    // Rising edge = trigger 1 tetes
    if (!phState.prevActived && phState.isActived && !phPumpRunning) {
      setRelay(RELAY_PH, true, "PH MANUAL tetes");
      phPumpRunning   = true;
      lastPhPumpStart = now;
    }
    return;
  }

  // -------- AUTO --------
  float ph = readPhValue();
  Serial.printf("[PH AUTO] pH:%.2f min:%.1f running:%s elapsed:%lus\n",
    ph, phMin, phPumpRunning ? "Y" : "N",
    (now - lastPhPumpStart) / 1000);

  if (ph < phMin) {
    // Belum cukup → tetes berkala setiap interval
    if (!phPumpRunning && (lastPhPumpStart == 0 || now - lastPhPumpStart >= phPumpInterval)) {
      setRelay(RELAY_PH, true, "PH AUTO tetes");
      phPumpRunning   = true;
      lastPhPumpStart = now;
    }
  } else {
    // Sudah cukup → pastikan mati, reset timer
    if (phPumpRunning) {
      setRelay(RELAY_PH, false, "PH AUTO stop (pH OK)");
      phPumpRunning = false;
    }
    lastPhPumpStart = now;
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
  while (WiFi.status() != WL_CONNECTED) { delay(500); Serial.print("."); }
  Serial.println("\nWiFi Connected");

  auth.user.email    = "zerxonin@gmail.com";
  auth.user.password = "123456";
  config.api_key               = API_KEY;
  config.database_url          = DATABASE_URL;
  config.token_status_callback = tokenStatusCallback;
  Firebase.begin(&config, &auth);
  fbdo.setBSSLBufferSize(4096, 1024);
  fbdoCtrl.setBSSLBufferSize(4096, 1024);
  Firebase.reconnectWiFi(true);
  Serial.println("Firebase Connected");

  esp32Id = WiFi.macAddress();
  esp32Id.replace(":", "");
  Serial.print("ESP32 ID: ");
  Serial.println(esp32Id);
}

void loop() {
  readTdsSampling();

  // Poll Firebase tiap 200ms
  if (millis() - lastFirebasePoll >= FIREBASE_POLL_INTERVAL) {
    lastFirebasePoll = millis();
    pollFirebase();
  }

  handleWaterPump();
  handleNutrientPump();
  handlePhPump();

  // Kirim sensor data tiap 5 detik
  if (Firebase.ready() && (millis() - lastSend >= 5000)) {
    lastSend = millis();

    if (Firebase.RTDB.getFloat(&fbdo, "/devices/" + esp32Id + "/water_max"))
      D_EMPTY = fbdo.floatData();

    float ph         = readPhValue();
    float tds        = readTdsValue();
    float dist       = readDistanceCm();
    float waterLevel = (dist > 0)
      ? constrain((D_EMPTY - dist) / (D_EMPTY - D_FULL) * 100.0, 0, 100)
      : 0;

    FirebaseJson json;
    json.set("ph",          ph);
    json.set("tds",         tds);
    json.set("water_level", waterLevel);
    json.set("updated_at",  millis());
    Firebase.RTDB.setJSON(&fbdo, ("/sensor_data/" + esp32Id).c_str(), &json);
    Firebase.RTDB.setInt(&fbdo, ("/devices/" + esp32Id + "/last_seen").c_str(), (long)time(nullptr) * 1000);

    Serial.printf("WL:%.1f%% pH:%.2f TDS:%.0fppm | W:%s N:%s P:%s\n",
      waterLevel, ph, tds,
      waterPumpRunning ? "ON":"OFF",
      nutPumpRunning   ? "ON":"OFF",
      phPumpRunning    ? "ON":"OFF");
  }
}