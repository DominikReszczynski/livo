import 'dart:io';
import 'package:cas_house/models/defect.dart';
import 'package:cas_house/models/property_short.dart';
import 'package:cas_house/providers/defects_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cas_house/sections/dashboard/multi_image_picker.dart';
import 'package:cas_house/models/properties.dart';
import 'package:cas_house/providers/properties_provider.dart';

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
  bool _isLoading = false;

  Property? _selectedProperty;
  List<Property> _rentedProperties = [];

  @override
  void initState() {
    super.initState();
    _fetchRentedProperties();
  }

  /// 🔹 Pobieramy listę wynajmowanych mieszkań z backendu
  Future<void> _fetchRentedProperties() async {
    final properties =
        await widget.propertiesProvider.getAllPropertiesByTenant();

    print("wynajęte mieszkania: $properties");

    setState(() {
      _rentedProperties = properties;
    });
  }

  /// 🔹 Walidacja i wysyłka formularza
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProperty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wybierz mieszkanie')),
      );
      return;
    }

    if (_imageFiles.isEmpty) {
      setState(() => _imageError = true);
      return;
    }

    setState(() => _isLoading = true);

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

      await Provider.of<DefectsProvider>(context, listen: false)
          .addDefect(defect, _imageFiles);

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Defekt został dodany.')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Błąd podczas dodawania defektu.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 🔹 Dropdown z wynajmowanymi mieszkaniami
                  DropdownButtonFormField<Property>(
                    value: _selectedProperty,
                    items: _rentedProperties
                        .map((p) => DropdownMenuItem<Property>(
                              value: p,
                              child: Text(p.name),
                            ))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedProperty = val;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Wybierz wynajęte mieszkanie',
                    ),
                    validator: (val) =>
                        val == null ? 'Wybierz mieszkanie' : null,
                  ),

                  _selectedProperty != null
                      ? Column(children: [
                          const SizedBox(height: 16),

                          /// 🔹 Tytuł defektu
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                                labelText: 'Tytuł defektu'),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Wymagany tytuł'
                                : null,
                          ),

                          const SizedBox(height: 16),

                          /// 🔹 Opis defektu
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                                labelText: 'Opis defektu'),
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Wymagany opis'
                                : null,
                          ),

                          const SizedBox(height: 16),

                          /// 🔹 Zdjęcia defektu
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
                              child: Text(
                                'Wymagane zdjęcia',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),

                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _submitForm,
                              icon: const Icon(Icons.report_problem),
                              label: const Text('Zgłoś defekt'),
                            ),
                          ),
                        ])
                      : Container(),
                ],
              ),
            ),
          );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
