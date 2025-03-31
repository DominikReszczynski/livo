import 'dart:io';

import 'package:cas_house/api_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as img_picker;
import 'package:http/http.dart' as http;

class SingleImageUploader extends StatefulWidget {
  const SingleImageUploader({super.key});

  @override
  State<SingleImageUploader> createState() => _SingleImageUploaderState();
}

class _SingleImageUploaderState extends State<SingleImageUploader> {
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = img_picker.ImagePicker(); // <- używamy aliasu
    final pickedFile =
        await picker.pickImage(source: img_picker.ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      await _uploadImage(_selectedImage!);
    }
  }

  Future<void> _uploadImage(File image) async {
    final String _urlPrefix = ApiService.baseUrl;
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_urlPrefix/upload/image'),
    );
    request.files.add(await http.MultipartFile.fromPath('image', image.path));
    final response = await request.send();

    if (response.statusCode == 200) {
      print('Upload OK');
    } else {
      print('Upload failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _pickImage,
          child: const Text("Dodaj zdjęcie"),
        ),
        if (_selectedImage != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.file(_selectedImage!, height: 150),
          )
      ],
    );
  }
}
