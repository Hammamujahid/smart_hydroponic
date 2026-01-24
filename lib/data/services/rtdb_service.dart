import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class RTDBService {
  final String deviceId;

  RTDBService(this.deviceId);

  static final FirebaseDatabase _db = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          "https://smart-hydroponic-14bcf-default-rtdb.asia-southeast1.firebasedatabase.app/");

  // ========== Device Status ==========
  DatabaseReference get _statusDevice => _db.ref("devices/$deviceId/status");

  Stream<String> getDeviceStatusStream() {
    return _statusDevice.onValue
        .map((event) => event.snapshot.value as String? ?? "offline");
  }

  // ========== Controller Mode ==========
  DatabaseReference get _autoModeRef => _db.ref("control/$deviceId/mode");

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

  DatabaseReference get _waterThresholdMinRef =>
      _db.ref("control/$deviceId/thresholds/water_min");

  DatabaseReference get _waterThresholdMaxRef =>
      _db.ref("control/$deviceId/thresholds/water_max");

  Stream<bool> getWaterControllerStream() {
    return _waterControllerRef.onValue
        .map((event) => event.snapshot.value as bool? ?? false);
  }

  Stream<double> getWaterThresholdMinStream(){
    return _waterThresholdMinRef.onValue
        .map((event) => (event.snapshot.value as num?)?.toDouble() ?? 0.0);
  }

  Stream<double> getWaterThresholdMaxStream(){
    return _waterThresholdMaxRef.onValue
        .map((event) => (event.snapshot.value as num?)?.toDouble() ?? 0.0);
  }

  Future<void> setWaterController(bool value) async {
    await _waterControllerRef.set(value);
  }

  Future<void> setWaterThresholdMin(double value) async {
    await _waterThresholdMinRef.set(value);
  }

  Future<void> setWaterThresholdMax(double value) async {
    await _waterThresholdMaxRef.set(value);
  }

  // ========== Nutrient Controller ==========
  DatabaseReference get _nutrientControllerRef =>
      _db.ref("control/$deviceId/nutrient");

  DatabaseReference get _nutrientThresholdMinRef =>
      _db.ref("control/$deviceId/thresholds/ec_min");

  DatabaseReference get _nutrientThresholdMaxRef =>
      _db.ref("control/$deviceId/thresholds/ec_max");

  Stream<bool> getNutrientControllerStream() {
    return _nutrientControllerRef.onValue
        .map((event) => event.snapshot.value as bool? ?? false);
  }

  Stream<double> getNutrientThresholdMinStream(){
    return _nutrientThresholdMinRef.onValue
        .map((event)=> (event.snapshot.value as num?)?.toDouble() ?? 0.0);
  }

  Stream<double> getNutrientThresholdMaxStream(){
    return _nutrientThresholdMaxRef.onValue
        .map((event)=> (event.snapshot.value as num?)?.toDouble() ?? 0.0);
  }

  Future<void> setNutrientController(bool value) async {
    await _nutrientControllerRef.set(value);
  }

  Future<void> setNutrientThresholdMin(double value) async {
    await _nutrientThresholdMinRef.set(value);
  }

  Future<void> setNutrientThresholdMax(double value) async {
    await _nutrientThresholdMaxRef.set(value);
  }

  // ========== Nutrient Sensor ==========
  DatabaseReference get _nutrientSensorRef =>
      _db.ref("sensor_data/$deviceId/ec");

  Stream<double> getNutrientSensorStream() {
    return _nutrientSensorRef.onValue
        .map((event) => (event.snapshot.value as num?)?.toDouble() ?? 0.0);
  }

  // ========== pH Sensor ==========
  DatabaseReference get _phSensorRef => _db.ref("sensor_data/$deviceId/ph");

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
