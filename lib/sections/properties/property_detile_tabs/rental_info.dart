import 'dart:io';
import 'package:cas_house/api_service.dart';
import 'package:cas_house/main_global.dart';
import 'package:cas_house/models/properties.dart';
import 'package:cas_house/providers/properties_provider.dart';
import 'package:cas_house/sections/dashboard/multi_image_picker.dart';
import 'package:cas_house/widgets/full_screen_image_viewer.dart';
import 'package:flutter/material.dart';

class RentalInfo extends StatefulWidget {
  final PropertiesProvider provider;
  final Property property;
  const RentalInfo({super.key, required this.property, required this.provider});

  @override
  _RentalInfoState createState() => _RentalInfoState();
}

class _RentalInfoState extends State<RentalInfo>
    with SingleTickerProviderStateMixin {
  List<File> pictures = [];

  @override
  Widget build(BuildContext context) {
    const String urlPrefix = ApiService.baseUrl;
    final hasImages = widget.property.imageFilenames?.isNotEmpty ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "documents".toUpperCase(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        if (widget.property.imageFilenames!.isNotEmpty ||
            widget.property.imageFilenames != null)
          Center(
              child: Text("Zdjęcia najmu",
                  style: Theme.of(context).textTheme.titleLarge)),
        const SizedBox(height: 12),
        if (!hasImages) ...[
          const Text('Brak załączonych zdjęć najmu.',
              style: TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          MultiImagePickerExample(
            onImageSelected: (List<File> files) => pictures = files,
            onUploadComplete: () async {
              await widget.provider.addRentalImagesToProperty(
                widget.property.id!,
                pictures,
              );
              if (mounted) setState(() {});
            },
          ),
        ] else
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: _MasonryImagesGrid(
                images: widget.property.imageFilenames!,
                baseUrl: urlPrefix,
              ),
            ),
          ),
      ],
    );
  }
}

class _MasonryImagesGrid extends StatelessWidget {
  final List<String> images;
  final String baseUrl;
  const _MasonryImagesGrid({required this.images, required this.baseUrl});

  String _url(String name) {
    if (name.startsWith('http://') || name.startsWith('https://')) return name;
    if (name.startsWith('/')) return '$baseUrl$name';
    return '$baseUrl/uploads/$name';
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final imageUrl = "$urlPrefix/uploads/${images[index]}";
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FullscreenImageViewer(
                  images: images,
                  initialIndex: index,
                  urlPrefix: urlPrefix,
                ),
              ),
            );
          },
          child: Hero(
            tag: imageUrl + index.toString(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
