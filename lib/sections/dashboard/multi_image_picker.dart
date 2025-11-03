import 'package:cas_house/api_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class MultiImagePickerExample extends StatefulWidget {
  final bool sendImagesButtonVisible;
  final Function(List<File> files) onImageSelected;

  const MultiImagePickerExample({
    super.key,
    this.sendImagesButtonVisible = true,
    required this.onImageSelected,
  });

  @override
  MultiImagePickerExampleState createState() => MultiImagePickerExampleState();
}

class MultiImagePickerExampleState extends State<MultiImagePickerExample> {
  final ImagePicker _picker = ImagePicker();
  List<XFile> _images = [];

  Future<void> _pickImages() async {
    final List<XFile> selectedImages = await _picker.pickMultiImage();

    if (selectedImages.isNotEmpty) {
      setState(() {
        _images = selectedImages;
      });

      // Konwersja XFile -> File i zwrócenie listy
      final List<File> files = selectedImages.map((x) => File(x.path)).toList();
      widget.onImageSelected(files);
    }
  }

  Future<void> _uploadImages() async {
    for (var image in _images) {
      const String urlPrefix = ApiService.baseUrl;
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$urlPrefix/upload/images'),
      );
      request.files
          .add(await http.MultipartFile.fromPath('images', image.path));
      var response = await request.send();

      if (response.statusCode == 200) {
        print("Upload ok");
      } else {
        print("Upload fail: ${response.statusCode}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _images.isNotEmpty
            ? SizedBox(
                height: 200,
                width: double.infinity,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(_images[index].path),
                              height: 180,
                              width: 180,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 5,
                            right: 5,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.close,
                                    color: Colors.white, size: 20),
                                onPressed: () {
                                  setState(() {
                                    _images.removeAt(index);
                                  });
                                  // Aktualizacja listy po usunięciu
                                  widget.onImageSelected(
                                    _images.map((x) => File(x.path)).toList(),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            : const SizedBox(),
        ElevatedButton(
          onPressed: _pickImages,
          child: const Text("Wybierz zdjęcia"),
        ),
        if (widget.sendImagesButtonVisible)
          ElevatedButton(
            onPressed: _uploadImages,
            child: const Text("Wyślij zdjęcia"),
          ),
      ],
    );
  }
}
