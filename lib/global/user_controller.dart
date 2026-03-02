import 'package:get/get.dart';
import '../../../models/user_model.dart';

class UserController extends GetxController {
  final Rx<UserModel?> _user = Rx<UserModel?>(null);

  UserModel? get user => _user.value;

  void setUser(UserModel userModel) {
    _user.value = userModel;
  }

  void clearUser() {
    _user.value = null;
  }
}
