import 'dart:convert';

import 'package:cas_house/main_global.dart';
import 'package:cas_house/models/user.dart';
import 'package:cas_house/services/user_services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  String? _token;
  String? get token => _token;

  bool get isAuthenticated => _token != null;
  bool get isLoggedIn => _token != null;

  bool _loggedIn = false;
  bool get loggedIn => _loggedIn;

  User? _user;
  User? get user => _user;

  UserProvider(this._prefs) {
    _token = _prefs.getString('accessToken');
    _loggedIn = _token != null;
    final userData = _prefs.getString('userData');

    print("AccessToken on startup: $_token");
    print("UserData: $userData");

    if (userData != null) {
      final Map<String, dynamic> userMap = jsonDecode(userData);
      _user = User.fromJson(userMap);
    }
    loggedUser = _user;
  }

  // Future<void> _loadLoginState() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   _loggedIn = prefs.getBool('loggedIn') ?? false;
  //   _user = prefs.getString('userId');
  //   notifyListeners();
  // }

  Future<bool> login({required String email, required String password}) async {
    try {
      final userServices = UserServices();
      final result = await userServices.login(email, password);
      if (result['success'] == true) {
        final accessToken = result['tokens']?['accessToken'];
        final refreshToken = result['tokens']?['refreshToken'];

        if (accessToken == null) {
          debugPrint('Brak accessToken w odpowiedzi!');
          return false;
        }

        // 💾 zapisz tokeny w SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accessToken', accessToken);
        if (refreshToken != null) {
          await prefs.setString('refreshToken', refreshToken);
        }
        await prefs.setBool('loggedIn', true);

        // 🧍 zapisz dane użytkownika
        await prefs.setString('userData', jsonEncode(result['user']));
        await prefs.setString('userId', result['user']['_id']);

        // 🔄 aktualizuj stan providera
        _token = accessToken;
        _loggedIn = true;
        _user = User.fromJson(result['user']);
        loggedUser = _user;

        notifyListeners();
        return true;
      } else {
        debugPrint('Błąd logowania: ${result['message']}');
        return false;
      }
    } catch (e) {
      debugPrint('Login error: $e');
      return false;
    }
  }

  Future<bool> register(
      {required String email,
      required String password,
      required String nickname,
      required String firstname,
      required String secondname,
      required String phone}) async {
    try {
      final userServices = UserServices();
      final result = await userServices.registration(
          email, password, nickname, phone, firstname, secondname);
      return result;
    } catch (e) {
      debugPrint('Registration error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _loggedIn = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('loggedIn');
    await prefs.remove('userData');
    notifyListeners();
  }

  Future<void> updateProfile({
    required String username,
    required String email,
    String? phone,
    String? firstname,
    String? secondname,
  }) async {
    final userService = UserServices();
    final result = await userService.updateProfile(
      username: username,
      email: email,
      phone: phone,
      firstname: firstname,
      secondname: secondname,
      token: _token,
      userIdForDev:
          _user?.id, // jeśli backend ma wyłączone auth – prześle userId
    );

    // Zakładam payload: { success:true, user:{...} }
    final updatedUserJson = result['user'] as Map<String, dynamic>?;

    if (updatedUserJson != null) {
      _user = User.fromJson(updatedUserJson);

      // zapisz do SharedPreferences
      await _prefs.setString('userData', jsonEncode(_user!.toJson()));
      // update globala, jeśli go używasz
      loggedUser = _user;

      notifyListeners();
    }
  }
}
