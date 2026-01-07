import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class RTDBService {
  static final FirebaseDatabase _db = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          "https://smart-hydroponic-14bcf-default-rtdb.asia-southeast1.firebasedatabase.app/");

  // ========== Controller Mode ==========
  static DatabaseReference get _autoModeRef =>
      _db.ref("control/mode");

  static Stream<String> getAutoModeStream() {
    return _autoModeRef.onValue
        .map((event) => event.snapshot.value as String? ?? "manual");
  }

  static Future<void> setAutoMode(String value) async {
    await _autoModeRef.set(value);
  }

  // ========== Water Controller ==========
  static DatabaseReference get _waterControllerRef =>
      _db.ref("control/water");

  static Stream<bool> getWaterControllerStream() {
    return _waterControllerRef.onValue
        .map((event) => event.snapshot.value as bool? ?? false);
  }

  static Future<void> setWaterController(bool value) async {
    await _waterControllerRef.set(value);
  }

  // ========== Nutrient Controller ==========
  static DatabaseReference get _nutrientControllerRef =>
      _db.ref("control/nutrient");

  static Stream<bool> getNutrientControllerStream() {
    return _nutrientControllerRef.onValue
        .map((event) => event.snapshot.value as bool? ?? false);
  }

  static Future<void> setNutrientController(bool value) async {
    await _nutrientControllerRef.set(value);
  }

  // ========== Nutrient Sensor ==========
  static DatabaseReference get _nutrientSensorRef =>
      _db.ref("sensor_data/8C4F0035DB1C/ec");

  static Stream<double> getNutrientSensorStream() {
    return _nutrientSensorRef.onValue
        .map((event) => (event.snapshot.value as num?)?.toDouble() ?? 0.0);
  }
}
