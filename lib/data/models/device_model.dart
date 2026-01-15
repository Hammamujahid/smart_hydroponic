import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceModel {
  final String deviceId;
  final String? userId;
  final String type;
  final DateTime createdAt;
  final DateTime updatedAt;

  DeviceModel({
    required this.deviceId,
    this.userId,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  DeviceModel copyWith({
    String? deviceId,
    String? userId,
    String? type,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DeviceModel(
      deviceId: deviceId ?? this.deviceId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory DeviceModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    return DeviceModel(
        deviceId: doc.id,
        userId: doc.data()!['userId'] as String?,
        type: doc.data()!['type'],
        createdAt: (doc.data()!['createdAt'] as Timestamp).toDate(),
        updatedAt: (doc.data()!['updatedAt'] as Timestamp).toDate());
  }

  Map<String, dynamic> toUpdateFirestore() {
    return {'userId': userId, 'updatedAt': Timestamp.fromDate(updatedAt)};
  }
}
