import 'package:cas_house/main_global.dart';
import 'package:cas_house/models/user.dart';
import 'package:cas_house/services/user_services.dart';
import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String? _token;
  String? get token => _token;

  bool get isAuthenticated => _token != null;
  bool get isLoggedIn => _token != null; // lub jak sprawdzasz login

  Future<bool> login({required String email, required String password}) async {
    try {
      final userServices = UserServices();
      final result = await userServices.login(email, password);
      if (result['success'] == true) {
        _token = result['token'];
        notifyListeners();
        loggedUser = User.fromMap(result['user']);
        return true;
      } else {
        _token = '1234567890';
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String nickname,
  }) async {
    try {
      final userServices = UserServices();
      final result = await userServices.registration(email, password, nickname);
      return result;
    } catch (e) {
      debugPrint('Registration error: $e');
      return false;
    }
  }

  void logout() {
    _token = null;
    notifyListeners();
  }
}
