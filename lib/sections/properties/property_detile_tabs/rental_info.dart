import 'dart:io';
import 'package:cas_house/api_service.dart';
import 'package:cas_house/main_global.dart';
import 'package:cas_house/models/properties.dart';
import 'package:cas_house/providers/properties_provider.dart';
import 'package:cas_house/widgets/generate_test_pdf_button.dart';
import 'package:cas_house/widgets/multi_image_picker.dart';
import 'package:cas_house/widgets/full_screen_image_viewer.dart';
import 'package:cas_house/widgets/property_documents_auto_upload.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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

    // Bezpieczne flagi
    final hasImages = (widget.property.imageFilenames?.isNotEmpty ?? false);
    final docs = widget.property.documents ?? [];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ======= DOCUMENTS =======
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                Center(
                  child: Text(
                    "Dokumenty najmu",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 8),
                // Center(child: GenerateTestPdfButton()),
                // const SizedBox(height: 8),

                // Lista dokumentów
                if (docs.isEmpty)
                  const Text('Brak dokumentów.', style: TextStyle(fontSize: 16))
                else
                  _DocumentsList(baseUrl: urlPrefix, filenames: docs),
                const SizedBox(height: 12),
                // Auto-upload przez onPdfsSelected; po sukcesie dopinamy do property.documents
                PropertyDocumentsAutoUploadSection(
                  baseUrl: urlPrefix,
                  propertyId: widget.property.id!,
                  onUploaded: (serverFilenames) {
                    final current = widget.property.documents ?? <String>[];
                    final set = {...current, ...serverFilenames};
                    setState(() {
                      widget.property.documents = set.toList();
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ======= IMAGES =======
          Center(
            child: Text(
              "Zdjęcia najmu",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: _MasonryImagesGrid(
                images: widget.property.imageFilenames!,
                baseUrl: urlPrefix,
              ),
            ),
        ],
      ),
    );
  }
}

/// Prosta lista dokumentów (otwieranie w systemowej przeglądarce)
class _DocumentsList extends StatelessWidget {
  final List<String> filenames;
  final String baseUrl;
  const _DocumentsList({required this.filenames, required this.baseUrl});

  String _urlOf(String name) {
    if (name.startsWith('http://') || name.startsWith('https://')) return name;
    if (name.startsWith('/')) return '$baseUrl$name';
    return '$baseUrl/uploads/$name';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: List.generate(filenames.length, (i) {
        final name = filenames[i];
        return Padding(
          padding: const EdgeInsets.only(
              bottom: 8), // minimalny odstęp między kafelkami
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              final url = Uri.parse(_urlOf(name));
              final ok =
                  await launchUrl(url, mode: LaunchMode.externalApplication);
              if (!ok && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Nie udało się otworzyć dokumentu')),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 6,
                    offset: Offset(0, 2),
                    color: Color(0x14000000),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.picture_as_pdf, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.chevron_right,
                      color: theme.iconTheme.color?.withOpacity(.7)),
                ],
              ),
            ),
          ),
        );
      }),
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
      shrinkWrap: true, // ważne w Column
      physics: const NeverScrollableScrollPhysics(), // scroll ogarnie rodzic
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final imageUrl = _url(images[index]); // poprawka: używamy helpera
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FullscreenImageViewer(
                  images: images,
                  initialIndex: index,
                  urlPrefix: baseUrl,
                ),
              ),
            );
          },
          child: Hero(
            tag: '$imageUrl#$index',
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
