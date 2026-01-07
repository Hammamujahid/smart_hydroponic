import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String userId;
  final String email;
  final String username;
  final String? deviceId;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.userId,
    required this.email,
    required this.username,
    this.deviceId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromFirestore (DocumentSnapshot<Map<String, dynamic>> doc){
    return UserModel(
      userId: doc.id,
      email: doc.data()!['email'],
      username: doc.data()!['username'],
      deviceId: doc.data()!['deviceId'] ?? '',
      createdAt: (doc.data()!['createdAt'] as Timestamp).toDate(),
      updatedAt: (doc.data()!['updatedAt'] as Timestamp).toDate()
    );
  }

  Map<String, dynamic> toFirestore(){
    return {
      'email': email,
      'username': username,
      'deviceId': deviceId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}