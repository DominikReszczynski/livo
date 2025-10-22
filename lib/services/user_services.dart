import 'dart:convert';

import 'package:cas_house/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UserServices {
  final String _urlPrefix = ApiService.baseUrl;

  Future<Map<String, String>> getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  login(String email, String password) async {
    print('UserServices: login');
    Map<String, dynamic> body = {'email': email, 'password': password};
    final http.Response res = await http.post(
      Uri.parse('$_urlPrefix/user/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );
    print(res.body);
    Map<String, dynamic> decodedBody = json.decode(res.body);
    print(decodedBody);
    print(1);
    return decodedBody;
  }

  registration(String email, String password, String name) async {
    print('UserServices: registration');
    Map<String, dynamic> body = {
      'email': email,
      'password': password,
      'username': name
    };
    final http.Response res = await http.post(
      Uri.parse('$_urlPrefix/user/registration'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );
    print(res.body);
    Map<String, dynamic> decodedBody = json.decode(res.body);
    print("blub " + jsonEncode(decodedBody['success']));

    return decodedBody['success'];
  }

  Future<Map<String, dynamic>> getProfile() async {
    print('UserServices: getProfile()');

    // 📥 Pobierz token z SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) {
      throw Exception('Brak tokenu — użytkownik nie jest zalogowany.');
    }

    final http.Response res = await http.get(
      Uri.parse(
          '$_urlPrefix/user/me'), // <-- dostosuj do swojego backendu (/auth/me lub /user/me)
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token', // 🔐 TOKEN JWT
      },
    );

    print('profile response: ${res.statusCode} ${res.body}');

    if (res.statusCode == 200) {
      return json.decode(res.body);
    } else if (res.statusCode == 401) {
      throw Exception('Token wygasł lub nieprawidłowy.');
    } else {
      throw Exception('Błąd: ${res.statusCode}');
    }
  }

  // 🚪 Wylogowanie (czyści token)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.setBool('loggedIn', false);
    print('UserServices: wylogowano');
  }
}
