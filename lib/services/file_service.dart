import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;

class FileApiService {
  final Dio _dio;

  /// baseUrl np. 'http://10.0.2.2:3000' (Android emulator) albo 'http://localhost:3000'
  FileApiService({required String baseUrl})
      : _dio = Dio(BaseOptions(baseUrl: baseUrl));

  /// Zwraca listę nazw zapisanych plików z backendu
  Future<List<String>> uploadDocuments({
    required List<File> files,
    String? token,
    Map<String, dynamic>? extraFields,
    void Function(int sent, int total)? onProgress,
  }) async {
    if (files.isEmpty) return [];

    final formData = FormData.fromMap(extraFields ?? {});
    for (final f in files) {
      formData.files.add(
        MapEntry(
          'documents',
          await MultipartFile.fromFile(
            f.path,
            filename: p.basename(f.path),
            // contentType można pominąć – Multer i tak czyta po rozszerzeniu/MIME
          ),
        ),
      );
    }

    final resp = await _dio.post(
      '/upload/documents',
      data: formData,
      options: Options(
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        contentType: 'multipart/form-data',
      ),
      onSendProgress: onProgress,
    );

    if (resp.statusCode == 200 && resp.data is Map) {
      final data = resp.data as Map;
      // Twój endpoint zwraca { success, filenames }, ale w MIX może być { documents: [...] }
      final list =
          (data['filenames'] ?? data['documents']) as List? ?? const [];
      return list.map((e) => e.toString()).toList();
    }
    throw DioException(
      requestOptions: resp.requestOptions,
      response: resp,
      error: 'Upload failed (${resp.statusCode})',
    );
  }
}
