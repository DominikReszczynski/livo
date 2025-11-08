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
  final List<XFile> _images = [];

  // Ustawienia wspólne dla obu kafelków (identyczny rozmiar!)
  static const double _tileSize = 180;
  static const BorderRadius _radius = BorderRadius.all(Radius.circular(12));
  static const EdgeInsets _tilePadding = EdgeInsets.all(4);

  Future<void> _pickImages() async {
    final List<XFile> selectedImages = await _picker.pickMultiImage();
    if (selectedImages.isEmpty) return;

    setState(() {
      _images.addAll(selectedImages);
    });

    widget.onImageSelected(_images.map((x) => File(x.path)).toList());
  }

  Future<void> _uploadImages() async {
    // TODO wysyłanie zdjęć i dodawanie do odpowiedniedniego property przez onImageSelected
    for (final image in _images) {
      try {
        const String urlPrefix = ApiService.baseUrl;
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('$urlPrefix/upload/images'),
        );
        request.files
            .add(await http.MultipartFile.fromPath('images', image.path));

        final response = await request.send();

        if (!mounted) continue;
        if (response.statusCode == 200) {
          debugPrint("Upload ok: ${image.path}");
        } else {
          debugPrint("Upload fail: ${response.statusCode}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Błąd wysyłki: ${response.statusCode}')),
          );
        }
      } catch (e) {
        debugPrint("Upload error: $e");
        if (!mounted) continue;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd wysyłki: $e')),
        );
      }
    }
  }

  // ---- Kafelki --------------------------------------------------------------

  Widget _addTile() {
    return SizedBox.square(
      dimension: _tileSize,
      child: ClipRRect(
        borderRadius: _radius,
        child: Material(
          color: Colors.black12,
          child: InkWell(
            onTap: _pickImages,
            child: const Center(
              child: Icon(Icons.add_a_photo, size: 48, color: Colors.black26),
            ),
          ),
        ),
      ),
    );
  }

  Widget _imageTile(int index) {
    final file = _images[index];
    return SizedBox.square(
      dimension: _tileSize,
      child: Stack(
        children: [
          // Obraz wypełnia cały kafelek 1:1
          ClipRRect(
            borderRadius: _radius,
            child: SizedBox.expand(
              child: Image.file(
                File(file.path),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // X do usuwania
          Positioned(
            top: 6,
            right: 6,
            child: Material(
              color: Colors.black.withOpacity(0.6),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  setState(() => _images.removeAt(index));
                  widget.onImageSelected(
                      _images.map((x) => File(x.path)).toList());
                },
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.close, size: 18, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- UI -------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // PUSTY STAN: jeden, wycentrowany kafelek „+”
    if (_images.isEmpty) {
      return Center(child: _addTile());
    }

    // LISTA: zdjęcia + kafelek dodawania na końcu
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: _tileSize + 20,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _images.length + 1,
            itemBuilder: (context, index) {
              if (index == _images.length) {
                return Padding(padding: _tilePadding, child: _addTile());
              }
              return Padding(padding: _tilePadding, child: _imageTile(index));
            },
          ),
        ),
        if (widget.sendImagesButtonVisible && _images.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: _uploadImages,
                child: const Text("Wyślij zdjęcia"),
              ),
            ),
          ),
      ],
    );
  }
}
