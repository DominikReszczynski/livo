import 'dart:convert';
import 'dart:io';
import 'package:cas_house/api_service.dart';
import 'package:cas_house/main_global.dart';
import 'package:cas_house/models/defect.dart';
import 'package:http/http.dart' as http;

class DefectsService {
  static const String _urlPrefix = ApiService.baseUrl;

  /// Dodaj nowy defekt — wraz z uploadem zdjęć
  static Future<Defect> addDefect(Defect defect, List<File> images) async {
    try {
      // 1️⃣ Upload zdjęć
      List<String> uploadedFilenames = [];
      if (images.isNotEmpty) {
        var uploadUrl = Uri.parse('${ApiService.baseUrl}/upload/images');
        var uploadRequest = http.MultipartRequest('POST', uploadUrl);
        for (var image in images) {
          uploadRequest.files
              .add(await http.MultipartFile.fromPath('images', image.path));
        }

        var uploadResponse = await uploadRequest.send();
        if (uploadResponse.statusCode == 200) {
          var body = await uploadResponse.stream.bytesToString();
          var jsonResponse = json.decode(body);
          uploadedFilenames = List<String>.from(jsonResponse['filenames']);
        } else {
          throw Exception("Błąd podczas uploadu zdjęć");
        }
      }

      // 2️⃣ Wysyłka defektu
      final uri = Uri.parse('${ApiService.baseUrl}/defect/addDefect');
      final body = jsonEncode({
        'propertyId': defect.property?.id, // 🔹 tylko ID mieszkania
        'title': defect.title,
        'description': defect.description,
        'status': defect.status,
        'imageFilenames': uploadedFilenames,
      });

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return Defect.fromJson(jsonData['defect']);
      } else {
        throw Exception('Błąd dodawania defektu: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [DefectsService.addDefect] $e');
      rethrow;
    }
  }

  static Future<List<Defect>> getAllDefects() async {
    try {
      final body = {'userID': loggedUser!.id};

      final res = await http.post(
        Uri.parse('$_urlPrefix/defect/getAllDefects'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(body),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true && data['defects'] != null) {
          final List<Defect> defects = (data['defects'] as List)
              .map((item) => Defect.fromJson(item))
              .toList();
          return defects;
        }
      }

      print('⚠️ Brak defektów lub niepoprawna odpowiedź');
      return [];
    } catch (e) {
      print('❌ Błąd pobierania defektów: $e');
      return [];
    }
  }
}
