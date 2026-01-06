import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String userId;
  final String email;
  final String username;
  final String? deviceId;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.userId,
    required this.email,
    required this.username,
    this.deviceId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromFirestore (DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options){
    final data = snapshot.data()!;
    return User(
      userId: snapshot.id,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      deviceId: data['deviceId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ??
          DateTime.fromMillisecondsSinceEpoch(0),
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