import 'dart:io';
import 'package:cas_house/main_global.dart';
import 'package:cas_house/widgets/pill_text_from_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cas_house/models/defect.dart';
import 'package:cas_house/models/property_short.dart';
import 'package:cas_house/models/properties.dart';
import 'package:cas_house/providers/defects_provider.dart';
import 'package:cas_house/providers/properties_provider.dart';
import 'package:cas_house/widgets/multi_image_picker.dart';

class AddNewDefectForm extends StatefulWidget {
  final PropertiesProvider propertiesProvider;
  const AddNewDefectForm({super.key, required this.propertiesProvider});

  @override
  State<AddNewDefectForm> createState() => _AddNewDefectFormState();
}

class _AddNewDefectFormState extends State<AddNewDefectForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<File> _imageFiles = [];
  bool _imageError = false;
  bool _isSubmitting = false;

  Property? _selectedProperty;
  List<Property> _rentedProperties = [];
  bool _listLoading = false;
  String? _listError;

  @override
  void initState() {
    super.initState();
    _fetchRentedProperties();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// pobranie lokali, gdzie zalogowany user jest najemcą
  Future<void> _fetchRentedProperties() async {
    setState(() {
      _listLoading = true;
      _listError = null;
    });
    try {
      final res = await widget.propertiesProvider.getAllPropertiesByTenant();
      final list = (res as List?)
              ?.whereType<Property?>()
              .where((p) => p != null)
              .map((p) => p!)
              .toList() ??
          <Property>[];
      if (!mounted) return;
      setState(() {
        _rentedProperties = list;
      });
    } catch (e) {
      setState(() => _listError = 'Nie udało się pobrać mieszkań');
    } finally {
      if (mounted) setState(() => _listLoading = false);
    }
  }

  bool get _canSubmit =>
      _selectedProperty != null &&
      _imageFiles.isNotEmpty &&
      _formKey.currentState?.validate() == true &&
      !_isSubmitting;

  Future<void> _submitForm() async {
    FocusScope.of(context).unfocus();
    setState(() => _imageError = _imageFiles.isEmpty);

    if (!_canSubmit) return;

    setState(() => _isSubmitting = true);
    try {
      final defect = Defect(
        property: PropertyShort(
          id: _selectedProperty!.id!,
          name: _selectedProperty!.name,
          location: _selectedProperty!.location,
        ),
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        status: "nowy",
      );

      await context.read<DefectsProvider>().addDefect(defect, _imageFiles);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Defekt został dodany.')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.red,
            content: Text('Błąd podczas dodawania defektu.')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  InputDecoration _pillDecoration({
    String? hintText,
    Widget? prefixIcon,
  }) {
    final theme = Theme.of(context);
    return InputDecoration(
      hintText: hintText,
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: theme.colorScheme.surface,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide(
          color: theme.colorScheme.primary.withOpacity(.35),
          width: 1.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_listLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // KARTA: wybór mieszkania
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Card(
                color: LivoColors.brandBeige,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Wybierz mieszkanie',
                            style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<Property>(
                        value: _selectedProperty,
                        items: _rentedProperties.map((p) {
                          return DropdownMenuItem<Property>(
                            value: p,
                            child:
                                Text(p.name, overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (val) =>
                            setState(() => _selectedProperty = val),
                        decoration: _pillDecoration(
                            prefixIcon: const Icon(Icons.apartment_outlined)),
                        validator: (val) =>
                            val == null ? 'Wybierz mieszkanie' : null,
                      ),
                      if (_listError != null) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(_listError!,
                              style: const TextStyle(color: Colors.red)),
                        ),
                      ],
                      if (_selectedProperty != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 18),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _selectedProperty!.location,
                                style: TextStyle(
                                    color: theme.textTheme.bodySmall?.color
                                        ?.withOpacity(.8)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ]
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // KARTA: dane defektu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Card(
                color: LivoColors.brandBeige,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      PillTextFormField(
                        controller: _titleController,
                        hintText: 'Tytuł defektu',
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Wymagany tytuł'
                            : null,
                        prefixIcon: const Icon(Icons.report_problem_outlined),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Wymagany opis'
                            : null,
                        decoration: _pillDecoration(
                            hintText: 'Opis defektu',
                            prefixIcon: const Icon(Icons.notes)),
                        key: const Key('defect-desc'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // KARTA: zdjęcia
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  MultiImagePickerExample(
                    sendImagesButtonVisible: false,
                    onImageSelected: (files) {
                      setState(() {
                        _imageFiles = List<File>.from(files);
                        _imageError = false;
                      });
                    },
                  ),
                  if (_imageError)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Wymagane zdjęcia',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // SUBMIT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _canSubmit ? _submitForm : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: LivoColors.brandGold,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(_isSubmitting ? 'Wysyłanie…' : 'Zgłoś defekt'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
