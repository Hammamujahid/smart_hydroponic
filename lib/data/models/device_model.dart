import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceModel {
  final String deviceId;
  final String? userId;
  final String? title;
  final DateTime createdAt;
  final DateTime updatedAt;

  DeviceModel({
    required this.deviceId,
    this.userId,
    this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  DeviceModel copyWith({
    String? deviceId,
    String? userId,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DeviceModel(
      deviceId: deviceId ?? this.deviceId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory DeviceModel.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    return DeviceModel(
        deviceId: doc.id,
        userId: doc.data()!['userId'] as String?,
        title: doc.data()!['title'] as String?,
        createdAt: (doc.data()!['createdAt'] as Timestamp).toDate(),
        updatedAt: (doc.data()!['updatedAt'] as Timestamp).toDate());
  }

  Map<String, dynamic> toUpdateFirestore() {
    return {
      'userId': userId,
      'title': title,
      'updatedAt': Timestamp.fromDate(updatedAt)
    };
  }

    Map<String, dynamic> toCreateFirestore() {
    return {
      'userId': userId,
      'title': title,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt)
    };
  }
}
