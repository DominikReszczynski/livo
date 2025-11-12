import 'dart:io';
import 'package:cas_house/services/file_service.dart';
import 'package:cas_house/widgets/multi_pdf_downloader.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class PropertyDocumentsAutoUploadSection extends StatefulWidget {
  final String baseUrl;
  final String propertyId;
  final String? token;
  final void Function(List<String> serverFilenames)? onUploaded;

  const PropertyDocumentsAutoUploadSection({
    super.key,
    required this.baseUrl,
    required this.propertyId,
    this.token,
    this.onUploaded,
  });

  @override
  State<PropertyDocumentsAutoUploadSection> createState() =>
      _PropertyDocumentsAutoUploadSectionState();
}

class _PropertyDocumentsAutoUploadSectionState
    extends State<PropertyDocumentsAutoUploadSection> {
  late final FileApiService _api = FileApiService(baseUrl: widget.baseUrl);

  // Ścieżki już wysłane (anty-duplikacja klienta)
  final Set<String> _uploadedPaths = {};

  // Nazwy z backendu (unikalne)
  final Set<String> _serverFilenames = {};

  bool _isUploading = false;
  double? _progress; // 0..1

  Future<void> _uploadNew(List<File> allPicked) async {
    // w razie czego: bez propertyId nie ma sensu wysyłać
    if (widget.propertyId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Brak propertyId — nie można wysłać dokumentów.')),
      );
      return;
    }

    // Wyślij tylko pliki, których jeszcze nie wysyłaliśmy
    final toSend =
        allPicked.where((f) => !_uploadedPaths.contains(f.path)).toList();
    if (toSend.isEmpty || _isUploading) return;

    setState(() {
      _isUploading = true;
      _progress = 0.0;
    });

    try {
      final names = await _api.uploadDocuments(
        files: toSend,
        token: widget.token,
        extraFields: {'propertyId': widget.propertyId}, // <— ważne
        onProgress: (sent, total) {
          if (total > 0) {
            final p = sent / total;
            if (mounted) setState(() => _progress = p);
          }
        },
      );

      if (!mounted) return;

      // Zaktualizuj lokalny stan i przekaż do rodzica
      setState(() {
        _serverFilenames.addAll(names);
        _uploadedPaths.addAll(toSend.map((e) => e.path));
      });
      widget.onUploaded?.call(names);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Wysłano ${toSend.length} plik(i).')),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.response?.data?.toString() ?? e.message ?? e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd uploadu: $msg')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd uploadu: $e')),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filenames = _serverFilenames.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Blokujemy interakcję podczas wysyłki, żeby nie klikać wielokrotnie
        AbsorbPointer(
          absorbing: _isUploading,
          child: Opacity(
            opacity: _isUploading ? 0.7 : 1,
            child: MultiPdfUploader(
              maxCount: 10,
              maxSizeInMB: 25,
              allowedExtensions: const ['pdf'],
              // ⬇️ auto-upload po wyborze
              onPdfsSelected: _uploadNew,
            ),
          ),
        ),

        if (_isUploading) ...[
          const SizedBox(height: 8),
          LinearProgressIndicator(value: _progress),
          if (_progress != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '${(_progress! * 100).toStringAsFixed(0)}%',
                textAlign: TextAlign.center,
              ),
            ),
        ],

        if (filenames.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text(
            'Nazwy zapisane na serwerze:',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          ...filenames.map((n) => Text('• $n')),
        ],
      ],
    );
  }
}
