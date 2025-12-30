#include <dummy.h>
#include <WiFi.h>
#include <Firebase_ESP_Client.h>

#define WIFI_SSID "WASIS FAMILY"
#define WIFI_PASSWORD "01021969"
#define DATABASE_URL "https://smart-hydroponic-14bcf-default-rtdb.asia-southeast1.firebasedatabase.app"
#define API_KEY "AIzaSyApu6dcDvBa2RsSkqjAEg_uomsx4zA61PY"
#define RELAY_AIR 26
#define RELAY_NUTRISI 27

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

String esp32Id;
unsigned long lastSend = 0;

void setup() {
  Serial.begin(115200);

  /* RELAY */
  pinMode(RELAY_AIR, OUTPUT);
  pinMode(RELAY_NUTRISI, OUTPUT);

  digitalWrite(RELAY_AIR, HIGH);
  digitalWrite(RELAY_NUTRISI, HIGH);

  /* Connect to WiFi */
  Serial.print("Connect to: ");
  Serial.println(WIFI_SSID);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("WiFi Connected");

  /* ESP32 ID */
  esp32Id = WiFi.macAddress();
  esp32Id.replace(":", "");

  Serial.print("ESP32 ID: ");
  Serial.println(esp32Id);

  /* Connect to Firebase */
  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;

  if (Firebase.signUp(&config, &auth, "", "")) {
    Serial.println("Anonymous sign-in OK");
  } else {
    Serial.printf("Sign-in failed: %s\n", config.signer.signupError.message.c_str());
  }

  Firebase.reconnectWiFi(true);
  Firebase.reconnectNetwork(true);
  fbdo.setBSSLBufferSize(4096, 1024);
  Firebase.begin(&config, &auth);

  Serial.println("Firebase Connected");
}

void loop() {
  if (Firebase.ready()) {
    if (millis() - lastSend > 5000) {
      lastSend = millis();
      sendSensorData();
      updateDeviceStatus();
    }
    listenControl();
  }
}

void sendSensorData() {
  float ph = random(55, 65) / 10.0;
  float ec = random(80, 120) / 100.0;
  int waterLevel = random(60, 90);

  String path = "/sensor_data/" + esp32Id;


  FirebaseJson json;
  json.set("ph", ph);
  json.set("ec", ec);
  json.set("water_level", waterLevel);
  json.set("updated_at", millis());

  if (Firebase.RTDB.setJSON(&fbdo, path.c_str(), &json)) {
    Serial.println("Sensor data sent");
  } else {
    Serial.println(fbdo.errorReason());
  }
}

void updateDeviceStatus() {
  String path = "/devices/" + esp32Id;

  FirebaseJson json;
  json.set("status", "online");
  json.set("last_seen", millis());

  Firebase.RTDB.updateNode(&fbdo, path.c_str(), &json);
}

void listenControl() {
  String path = "/control/" + esp32Id;

  if (Firebase.RTDB.getJSON(&fbdo, path.c_str())) {
    FirebaseJson &json = fbdo.jsonObject();

    bool pumpAir = false;
    bool pumpNutrisi = false;
    String mode = "auto";

    FirebaseJsonData data;

    json.get(data, "pump_air/value");
    if (data.success) pumpAir = data.boolValue;

    json.get(data, "pump_nutrisi/value");
    if (data.success) pumpNutrisi = data.boolValue;

    json.get(data, "mode");
    if (data.success) mode = data.stringValue;

    // ======== RELAY CONTROL ========
    digitalWrite(RELAY_AIR, pumpAir ? LOW : HIGH);
    digitalWrite(RELAY_NUTRISI, pumpNutrisi ? LOW : HIGH);

    Serial.printf("Mode: %s | Air: %d | Nutrisi: %d\n",
                  mode.c_str(), pumpAir, pumpNutrisi);
  }
}
