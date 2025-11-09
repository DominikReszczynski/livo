import 'dart:convert';
import 'dart:io';

import 'package:cas_house/api_service.dart';
import 'package:cas_house/main_global.dart';
import 'package:cas_house/models/properties.dart';
import 'package:cas_house/services/user_services.dart';
import 'package:http/http.dart' as http;

class PropertyServices {
  final String _urlPrefix = ApiService.baseUrl;

  Future<Property?> addProperty(Property property, File? imageFile) async {
    final uri = Uri.parse('$_urlPrefix/property/addProperty');
    final request = http.MultipartRequest('POST', uri);

    final headers = await UserServices().getAuthHeaders();
    request.headers.addAll(headers);

    // Dodaj dane JSON jako pole tekstowe
    request.fields['property'] = jsonEncode(property.toJson());

    // Dodaj plik jako multipart
    if (imageFile != null) {
      request.files
          .add(await http.MultipartFile.fromPath('image', imageFile.path));
    }

    // Wyślij żądanie
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final Map<String, dynamic> decoded = json.decode(response.body);
      if (decoded['success']) {
        print(decoded['property']);
        return Property.fromJson(decoded['property']);
      }
    }

    return null;
  }

  Future<List<Property?>?> getAllPropertiesByOwner() async {
    // final prefs = await SharedPreferences.getInstance();
    // final storedUserId = prefs.getString('userId');

    print(loggedUser!.id);
    Map<String, dynamic> body = {
      'userID': loggedUser!.id,
    };
    final http.Response res = await http.post(
      Uri.parse('$_urlPrefix/property/getAllByOwner'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );
    print(res.body);
    Map<String, dynamic> decodedBody = json.decode(res.body);
    if (decodedBody['success']) {
      List<Property> properties = [];
      for (var property in decodedBody['properties']) {
        properties.add(Property.fromJson(property));
      }
      return properties;
    }
    return null;
  }

  Future<List<Property?>?> getAllPropertiesByTenant() async {
    // final prefs = await SharedPreferences.getInstance();
    // final storedUserId = prefs.getString('userId');
    // print(storedUserId);
    Map<String, dynamic> body = {
      'userID': loggedUser!.id,
    };
    final http.Response res = await http.post(
      Uri.parse('$_urlPrefix/property/getAllByTenant'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );
    print(res.body);
    Map<String, dynamic> decodedBody = json.decode(res.body);
    if (decodedBody['success']) {
      List<Property> properties = [];
      for (var property in decodedBody['properties']) {
        properties.add(Property.fromJson(property));
      }
      return properties;
    }
    return null;
  }

  Future<bool> setPin(String propertyID, String pin) async {
    print(loggedUser!.id);
    Map<String, dynamic> body = {
      'propertyID': propertyID,
      'pin': pin,
    };
    final http.Response res = await http.post(
      Uri.parse('$_urlPrefix/property/setPin'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );
    print(res.body);
    Map<String, dynamic> decodedBody = json.decode(res.body);
    if (decodedBody['success']) {
      return true;
    }
    return false;
  }

  Future<bool> removePin(String propertyID) async {
    print(loggedUser!.id);
    Map<String, dynamic> body = {
      'propertyID': propertyID,
    };
    final http.Response res = await http.post(
      Uri.parse('$_urlPrefix/property/removePin'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );
    print(res.body);
    Map<String, dynamic> decodedBody = json.decode(res.body);
    if (decodedBody['success']) {
      return true;
    }
    return false;
  }

  Future addTenantToProperty(
      String propertyID, String pin, String tenantID) async {
    Map<String, dynamic> body = {
      'propertyID': propertyID,
      'pin': pin,
      'tenantID': tenantID,
    };
    final http.Response res = await http.post(
      Uri.parse('$_urlPrefix/property/addTenantToProperty'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );
    print(res.body);
    Map<String, dynamic> decodedBody = json.decode(res.body);
    if (decodedBody['success']) {
      Property result = Property.fromJson(decodedBody['property']);
      return result;
    }
    return null;
  }

// add rental images and documents in future
  Future<List<String>> addRentalImages(
      String propertyId, List<File> images) async {
    print(
        "Dodawanie zdjęć do mieszkania o ID: $propertyId, liczba zdjęć: ${images.length}");
    // 1) upload zdjęć
    List<String> uploadedFilenames = [];
    if (images.isNotEmpty) {
      final uploadUrl = Uri.parse('${ApiService.baseUrl}/upload/images');
      final uploadRequest = http.MultipartRequest('POST', uploadUrl);

      for (final img in images) {
        uploadRequest.files.add(
          await http.MultipartFile.fromPath('images', img.path),
        );
      }

      final uploadResponse = await uploadRequest.send();
      final body = await uploadResponse.stream.bytesToString();

      if (uploadResponse.statusCode != 200) {
        throw Exception(
            'Błąd uploadu zdjęć (${uploadResponse.statusCode}): $body');
      }
      final jsonResponse = json.decode(body);
      uploadedFilenames =
          List<String>.from(jsonResponse['filenames'] ?? const []);
    }

    // 2) przypięcie listy nazw do mieszkania
    final uri = Uri.parse('${ApiService.baseUrl}/property/addRentalImages');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'propertyId': propertyId, // u Ciebie ID to String
        'imageFilenames': uploadedFilenames,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body);
      return uploadedFilenames;
    } else {
      throw Exception(
          'Błąd przypięcia zdjęć: ${response.statusCode} ${response.body}');
    }
  }
}
