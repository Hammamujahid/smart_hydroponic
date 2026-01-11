import 'package:smart_hydroponic/data/models/user_model.dart';
import 'package:smart_hydroponic/data/services/user_service.dart';

class UserRepository {
  final UserService service;

  UserRepository(this.service);

  Future<void> updateUserById(UserModel user) async {
    await service.updateUserById(user.userId, user.toFirestore());
  }
}