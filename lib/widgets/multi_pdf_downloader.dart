import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

class MultiPdfUploader extends StatefulWidget {
  final void Function(List<File>) onPdfsSelected;
  final int? maxSizeInMB; // limit na 1 plik (np. 10)
  final int? maxCount; // limit liczby plików (np. 10)
  final List<String> allowedExtensions; // np. ['pdf'] albo ['pdf','doc','docx']

  const MultiPdfUploader({
    super.key,
    required this.onPdfsSelected,
    this.maxSizeInMB,
    this.maxCount,
    this.allowedExtensions = const ['pdf'],
  });

  @override
  State<MultiPdfUploader> createState() => _MultiPdfUploaderState();
}

class _PickedDoc {
  final File file;
  final String name;
  final int sizeBytes;
  _PickedDoc({required this.file, required this.name, required this.sizeBytes});
}

class _MultiPdfUploaderState extends State<MultiPdfUploader> {
  static const double _tileSize = 180;
  static const BorderRadius _radius = BorderRadius.all(Radius.circular(12));

  final List<_PickedDoc> _docs = [];

  bool get _canOpenWithOS {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid ||
          Platform.isIOS ||
          Platform.isMacOS ||
          Platform.isWindows ||
          Platform.isLinux;
    } catch (_) {
      return false;
    }
  }

  Future<void> _pickPdfs() async {
    final remaining =
        widget.maxCount == null ? null : (widget.maxCount! - _docs.length);
    if (remaining != null && remaining <= 0) {
      _toast('Osiągnięto maksymalną liczbę plików: ${widget.maxCount}');
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: widget.allowedExtensions,
      withData: false,
    );
    if (result == null) return;

    int skippedBySize = 0;
    int skippedDuplicate = 0;

    final toAdd = <_PickedDoc>[];
    for (final pf in result.files) {
      final path = pf.path;
      if (path == null) continue;

      // limit count (ucina nadmiar jeszcze przed dodaniem)
      if (remaining != null && (toAdd.length >= remaining)) break;

      // duplicates (po ścieżce)
      final exists = _docs.any((d) => d.file.path == path) ||
          toAdd.any((d) => d.file.path == path);
      if (exists) {
        skippedDuplicate++;
        continue;
      }

      final f = File(path);
      final size = pf.size; // szybciej niż await f.length()
      if (widget.maxSizeInMB != null) {
        final limitBytes = widget.maxSizeInMB! * 1024 * 1024;
        if (size > limitBytes) {
          skippedBySize++;
          continue;
        }
      }

      toAdd.add(_PickedDoc(file: f, name: pf.name, sizeBytes: size));
    }

    if (toAdd.isEmpty && skippedBySize == 0 && skippedDuplicate == 0) return;

    setState(() {
      _docs.addAll(toAdd);
    });
    widget.onPdfsSelected(_docs.map((e) => e.file).toList());

    if (skippedBySize > 0) {
      _toast('Pominięto $skippedBySize plik(i) — przekroczony limit rozmiaru'
          '${widget.maxSizeInMB != null ? ' (${widget.maxSizeInMB} MB)' : ''}.');
    }
    if (skippedDuplicate > 0) {
      _toast('Pominięto $skippedDuplicate zduplikowane plik(i).');
    }
  }

  void _removeAt(int index) {
    setState(() {
      _docs.removeAt(index);
    });
    widget.onPdfsSelected(_docs.map((e) => e.file).toList());
  }

  void _clearAll() {
    setState(() => _docs.clear());
    widget.onPdfsSelected(const []);
  }

  String _formatSize(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB'];
    double size = bytes.toDouble();
    int unit = 0;
    while (size >= 1024 && unit < units.length - 1) {
      size /= 1024;
      unit++;
    }
    return '${size.toStringAsFixed(size < 10 ? 1 : 0)} ${units[unit]}';
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final canAddMore =
        widget.maxCount == null || _docs.length < widget.maxCount!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Kafelek "Dodaj"
        if (canAddMore)
          SizedBox.square(
            dimension: _tileSize,
            child: ClipRRect(
              borderRadius: _radius,
              child: Material(
                color: Colors.black12,
                child: InkWell(
                  onTap: _pickPdfs,
                  child: const Center(
                    child: Icon(Icons.picture_as_pdf,
                        size: 48, color: Colors.black26),
                  ),
                ),
              ),
            ),
          ),

        if (_docs.isNotEmpty) const SizedBox(height: 8),

        // Lista wybranych
        ...List.generate(_docs.length, (i) {
          final d = _docs[i];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(10),
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
                  const Icon(Icons.picture_as_pdf, size: 32),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(_formatSize(d.sizeBytes),
                            style: TextStyle(color: theme.hintColor)),
                      ],
                    ),
                  ),
                  if (_canOpenWithOS)
                    IconButton(
                      tooltip: 'Otwórz',
                      icon: const Icon(Icons.open_in_new),
                      onPressed: () async {
                        try {
                          await OpenFilex.open(d.file.path);
                        } catch (e) {
                          _toast('Nie udało się otworzyć: $e');
                        }
                      },
                    ),
                  IconButton(
                    tooltip: 'Usuń',
                    icon: const Icon(Icons.close),
                    onPressed: () => _removeAt(i),
                  ),
                ],
              ),
            ),
          );
        }),

        if (_docs.isNotEmpty)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: _clearAll,
              icon: const Icon(Icons.delete_sweep),
              label: const Text('Wyczyść wszystkie'),
            ),
          ),
      ],
    );
  }
}
