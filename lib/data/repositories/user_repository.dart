import 'package:smart_hydroponic/data/models/user_model.dart';
import 'package:smart_hydroponic/data/services/user_service.dart';

class UserRepository {
  final UserService _service;

  UserRepository(this._service);

  Future<UserModel?> getUserById(String uid) async {
    final doc = await _service.getUserById(uid);
    if (!doc.exists) {
      return null;
    }
    return UserModel.fromFirestore(doc);
  }

  Future<void> updateUserById(UserModel user) {
    return _service.updateUserById(user.userId, user.toUpdateFirestore());
  }
}
