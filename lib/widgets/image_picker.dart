import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as img_picker;

class SingleImageUploader extends StatefulWidget {
  final void Function(File) onImageSelected;
  final String? initialImageUrl; // 🔹 nowy parametr – opcjonalny URL zdjęcia

  const SingleImageUploader({
    super.key,
    required this.onImageSelected,
    this.initialImageUrl,
  });

  @override
  State<SingleImageUploader> createState() => _SingleImageUploaderState();
}

class _SingleImageUploaderState extends State<SingleImageUploader> {
  File? _selectedImage;
  bool _isNetworkImage = false;

  @override
  void initState() {
    super.initState();
    // 🔹 Jeśli przekazano URL — pokaż je jako obraz sieciowy
    if (widget.initialImageUrl != null && widget.initialImageUrl!.isNotEmpty) {
      _isNetworkImage = true;
    }
  }

  Future<void> _pickImage() async {
    final picker = img_picker.ImagePicker();
    final pickedFile =
        await picker.pickImage(source: img_picker.ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _isNetworkImage =
            false; // 🔹 po wybraniu z galerii nie pokazuj już z sieci
      });
      widget.onImageSelected(_selectedImage!);
    }
  }

  static const double _tileSize = 180;
  static const BorderRadius _radius = BorderRadius.all(Radius.circular(12));

  @override
  Widget build(BuildContext context) {
    final showPlaceholder = _selectedImage == null && !_isNetworkImage;

    return Column(
      children: [
        if (showPlaceholder)
          SizedBox.square(
            dimension: _tileSize,
            child: ClipRRect(
              borderRadius: _radius,
              child: Material(
                color: Colors.black12,
                child: InkWell(
                  onTap: _pickImage,
                  child: const Center(
                    child: Icon(Icons.add_a_photo,
                        size: 48, color: Colors.black26),
                  ),
                ),
              ),
            ),
          ),
        if (_isNetworkImage && _selectedImage == null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    widget.initialImageUrl!,
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                    errorBuilder: (context, error, stack) => Container(
                      color: Colors.black12,
                      height: _tileSize,
                      child: const Center(
                        child: Icon(Icons.broken_image,
                            size: 40, color: Colors.black26),
                      ),
                    ),
                  ),
                ),
                _buildRemoveButton(),
              ],
            ),
          ),
        if (_selectedImage != null)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    _selectedImage!,
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                _buildRemoveButton(),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildRemoveButton() {
    return Positioned(
      top: 5,
      right: 5,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.close, color: Colors.white, size: 20),
          onPressed: () {
            setState(() {
              _selectedImage = null;
              _isNetworkImage = false;
            });
          },
        ),
      ),
    );
  }
}
