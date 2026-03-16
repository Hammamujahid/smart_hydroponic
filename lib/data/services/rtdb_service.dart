import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class RTDBService {
  final String deviceId;

  RTDBService(this.deviceId);

  static final FirebaseDatabase _db = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL:
          "https://smart-hydroponic-14bcf-default-rtdb.asia-southeast1.firebasedatabase.app/");

  // ========== Cek Device ==========
  static Future<bool> deviceExists(String deviceId) async {
    final snapshot = await _db.ref("devices/$deviceId").get();
    return snapshot.exists;
  }

  // ========== Device Status ==========
  DatabaseReference get _statusDevice => _db.ref("devices/$deviceId/last_seen");

  DatabaseReference get _waterMaxRef => _db.ref("devices/$deviceId/water_max");

  Stream<int> getDeviceStatusStream() {
    return _statusDevice.onValue
        .map((event) => event.snapshot.value as int? ?? 0);
  }

  Stream<double> getWaterMaxStream() {
    return _waterMaxRef.onValue
        .map((event) => (event.snapshot.value as num?)?.toDouble() ?? 0.0);
  }

  Future<void> setWaterMax(double value) async {
    await _waterMaxRef.set(value);
  }

  // ========== Water Controller ==========
  DatabaseReference get _waterControllerRef =>
      _db.ref("control/$deviceId/water/isActived");

  DatabaseReference get _waterModeRef =>
      _db.ref("control/$deviceId/water/mode");

  DatabaseReference get _waterIntervalRef =>
      _db.ref("control/$deviceId/water/interval");

  DatabaseReference get _waterDurationRef =>
      _db.ref("control/$deviceId/water/duration");

  Stream<bool> getWaterControllerStream() {
    return _waterControllerRef.onValue
        .map((event) => event.snapshot.value as bool? ?? false);
  }

  Stream<String> getWaterModeStream() {
    return _waterModeRef.onValue
        .map((event) => event.snapshot.value as String? ?? "manual");
  }

  Stream<double> getWaterIntervalStream() {
    return _waterIntervalRef.onValue
        .map((event) => (event.snapshot.value as num?)?.toDouble() ?? 0.0);
  }

  Stream<double> getWaterDurationStream() {
    return _waterDurationRef.onValue
        .map((event) => (event.snapshot.value as num?)?.toDouble() ?? 0.0);
  }

  Future<void> setWaterController(bool value) async {
    await _waterControllerRef.set(value);
  }

  Future<void> setWaterMode(String value) async {
    await _waterModeRef.set(value);
  }

  Future<void> setWaterInterval(double value) async {
    await _waterIntervalRef.set(value);
  }

  Future<void> setWaterDuration(double value) async {
    await _waterDurationRef.set(value);
  }

  // ========== Nutrient Controller ==========
  DatabaseReference get _nutrientControllerRef =>
      _db.ref("control/$deviceId/nutrient/isActived");

  DatabaseReference get _nutrientThresholdMinRef =>
      _db.ref("control/$deviceId/nutrient/tds_min");

  DatabaseReference get _nutrientThresholdMaxRef =>
      _db.ref("control/$deviceId/nutrient/tds_max");

  DatabaseReference get _nutrientModeRef =>
      _db.ref("control/$deviceId/nutrient/mode");

  Stream<bool> getNutrientControllerStream() {
    return _nutrientControllerRef.onValue
        .map((event) => event.snapshot.value as bool? ?? false);
  }

  Stream<double> getNutrientThresholdMinStream() {
    return _nutrientThresholdMinRef.onValue
        .map((event) => (event.snapshot.value as num?)?.toDouble() ?? 0.0);
  }

  Stream<double> getNutrientThresholdMaxStream() {
    return _nutrientThresholdMaxRef.onValue
        .map((event) => (event.snapshot.value as num?)?.toDouble() ?? 0.0);
  }

  Stream<String> getNutrientModeStream(){
    return _nutrientModeRef.onValue
        .map((event) => event.snapshot.value as String? ?? "manual");
  }

  Future<void> setNutrientController(bool value) async {
    await _nutrientControllerRef.set(value);
  }

  Future<void> setNutrientMode(String value) async {
    await _nutrientModeRef.set(value);
  }

  Future<void> setNutrientThresholdMin(double value) async {
    await _nutrientThresholdMinRef.set(value);
  }

  Future<void> setNutrientThresholdMax(double value) async {
    await _nutrientThresholdMaxRef.set(value);
  }

  // ========== Nutrient Sensor ==========
  DatabaseReference get _nutrientSensorRef =>
      _db.ref("sensor_data/$deviceId/tds");

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
