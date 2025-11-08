import 'dart:io';

import 'package:cas_house/api_service.dart';
import 'package:cas_house/models/properties.dart';
import 'package:cas_house/providers/properties_provider.dart';
import 'package:cas_house/sections/dashboard/multi_image_picker.dart';
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
  @override
  Widget build(BuildContext context) {
    const String urlPrefix = ApiService.baseUrl;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("documents".toUpperCase(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        widget.property.imageFilenames == null ||
                widget.property.imageFilenames!.isEmpty
            ? Column(
                children: [
                  const Text('Brak załączonych dokumentów najmu.',
                      style: TextStyle(fontSize: 16)),
                  MultiImagePickerExample(
                    onImageSelected: (List<File> files) {},
                  ),
                ],
              )
            : Text("zdjęcia"),
      ],
    );
  }
}
