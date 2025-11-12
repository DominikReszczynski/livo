import 'dart:convert';
import 'package:cas_house/main_global.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:3000';

  static Map<String, String> headers(
      {required String? token, Map<String, String>? extra}) {
    final h = <String, String>{
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }
    if (extra != null) h.addAll(extra);
    return h;
  }
}
