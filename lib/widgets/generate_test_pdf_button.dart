import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_filex/open_filex.dart';

class GenerateTestPdfButton extends StatefulWidget {
  const GenerateTestPdfButton({super.key});

  @override
  State<GenerateTestPdfButton> createState() => _GenerateTestPdfButtonState();
}

class _GenerateTestPdfButtonState extends State<GenerateTestPdfButton> {
  bool _isSaving = false;

  Future<void> _generateAndSavePdf() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      // 1) Zbuduj prosty PDF
      final doc = pw.Document();
      final now = DateTime.now();

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (ctx) => pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Livo — Test PDF',
                    style: pw.TextStyle(
                      fontSize: 26,
                      fontWeight: pw.FontWeight.bold,
                    )),
                pw.SizedBox(height: 12),
                pw.Text('Generated: $now'),
                pw.SizedBox(height: 24),
                pw.Text(
                    'To jest testowy dokument PDF wygenerowany w aplikacji.'),
                pw.SizedBox(height: 16),
                pw.Table.fromTextArray(
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  data: <List<String>>[
                    <String>['Field', 'Value'],
                    <String>['App', 'Livo'],
                    <String>['Purpose', 'Test PDF generation'],
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      final bytes = await doc.save();

      // 2) Ścieżka zapisu (Documents aplikacji – bez dodatkowych uprawnień)
      final dir = await getApplicationDocumentsDirectory();
      final filename = 'livo_test_${now.millisecondsSinceEpoch}.pdf';
      final file = File('${dir.path}/$filename');

      await file.writeAsBytes(bytes);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Zapisano: ${file.path}')),
      );

      // 3) Otwórz systemowym viewerem (jeśli możliwe)
      try {
        await OpenFilex.open(file.path);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Zapisano, ale nie udało się otworzyć: $e')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd tworzenia PDF: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: _isSaving ? null : _generateAndSavePdf,
      icon: const Icon(Icons.picture_as_pdf),
      label: Text(_isSaving ? 'Zapisywanie…' : 'Utwórz testowy PDF'),
    );
  }
}
