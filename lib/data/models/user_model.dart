import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String email;
  final String username;
  final String? activeDeviceId;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.userId,
    required this.email,
    required this.username,
    this.activeDeviceId,
    required this.createdAt,
    required this.updatedAt,
  });

  UserModel copyWith(
      {String? userId,
      String? email,
      String? username,
      String? activeDeviceId,
      DateTime? createdAt,
      DateTime? updatedAt}) {
    return UserModel(
        userId: userId ?? this.userId,
        email: email ?? this.email,
        username: username ?? this.username,
        activeDeviceId: activeDeviceId ?? this.activeDeviceId,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt);
  }

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return UserModel(
        userId: doc.id,
        email: doc.data()!['email'],
        username: doc.data()!['username'],
        activeDeviceId: doc.data()!['activeDeviceId'] as String?,
        createdAt: (doc.data()!['createdAt'] as Timestamp).toDate(),
        updatedAt: (doc.data()!['updatedAt'] as Timestamp).toDate());
  }

  Map<String, dynamic> toUpdateFirestore() {
    return {
      'username': username,
      'activeDeviceId': activeDeviceId,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
