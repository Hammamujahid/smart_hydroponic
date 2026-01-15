import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
 
class RTDBService{
  final String deviceId;

  RTDBService(this.deviceId);

  static final FirebaseDatabase _db = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          "https://smart-hydroponic-14bcf-default-rtdb.asia-southeast1.firebasedatabase.app/");

  // ========== Controller Mode ==========
  DatabaseReference get _autoModeRef =>
      _db.ref("control/$deviceId/mode");

  Stream<String> getAutoModeStream() {
    return _autoModeRef.onValue
        .map((event) => event.snapshot.value as String? ?? "manual");
  }

  Future<void> setAutoMode(String value) async {
    await _autoModeRef.set(value);
  }

  // ========== Water Controller ==========
  DatabaseReference get _waterControllerRef =>
      _db.ref("control/$deviceId/water");

  Stream<bool> getWaterControllerStream() {
    return _waterControllerRef.onValue
        .map((event) => event.snapshot.value as bool? ?? false);
  }

  Future<void> setWaterController(bool value) async {
    await _waterControllerRef.set(value);
  }

  // ========== Nutrient Controller ==========
  DatabaseReference get _nutrientControllerRef =>
      _db.ref("control/$deviceId/nutrient");

  Stream<bool> getNutrientControllerStream() {
    return _nutrientControllerRef.onValue
        .map((event) => event.snapshot.value as bool? ?? false);
  }

  Future<void> setNutrientController(bool value) async {
    await _nutrientControllerRef.set(value);
  }

  // ========== Nutrient Sensor ==========
  DatabaseReference get _nutrientSensorRef =>
      _db.ref("sensor_data/$deviceId/ec");

  Stream<double> getNutrientSensorStream() {
    return _nutrientSensorRef.onValue
        .map((event) => (event.snapshot.value as num?)?.toDouble() ?? 0.0);
  }

  // ========== pH Sensor ==========
  DatabaseReference get _phSensorRef =>
      _db.ref("sensor_data/$deviceId/ph");

  Stream<double> getpHSensorStream() {
    return _phSensorRef.onValue
        .map((event) => (event.snapshot.value as num?)?.toDouble() ?? 0.0);
  }

  // ========== Water Sensor ==========
  DatabaseReference get _waterSensorRef =>
      _db.ref("sensor_data/$deviceId/water_level");

  Stream<double> getWaterSensorStream() {
    return _waterSensorRef.onValue
        .map((event) => (event.snapshot.value as num?)?.toDouble() ?? 0.0);
  }
}
