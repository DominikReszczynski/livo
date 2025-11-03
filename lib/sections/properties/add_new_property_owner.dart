import 'dart:io';

import 'package:cas_house/main_global.dart';
import 'package:cas_house/models/properties.dart';
import 'package:cas_house/sections/dashboard/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cas_house/providers/properties_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddNewPropertyOwner extends StatefulWidget {
  const AddNewPropertyOwner(
      {super.key, required PropertiesProvider propertiesProvider});

  @override
  State<AddNewPropertyOwner> createState() => _AddNewPropertyOwnerState();
}

class _AddNewPropertyOwnerState extends State<AddNewPropertyOwner> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _roomsController = TextEditingController();
  final TextEditingController _floorController = TextEditingController();
  final TextEditingController _rentAmountController = TextEditingController();
  final TextEditingController _depositAmountController =
      TextEditingController();
  final TextEditingController _paymentCycleController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  File? _imageFile;
  bool _imageError = false;

  String _status = 'wolne';
  DateTime? _rentalStart;
  DateTime? _rentalEnd;
  String? _dateError;

  List<String> _features = [];

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _sizeController.dispose();
    _roomsController.dispose();
    _floorController.dispose();
    _rentAmountController.dispose();
    _depositAmountController.dispose();
    _paymentCycleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    // reset non-form errors first
    setState(() {
      _imageError = false;
      _dateError = null;
    });

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // image validation
    if (_imageFile == null) {
      setState(() {
        _imageError = true;
      });
      return;
    }

    // date validation
    if (_rentalStart == null || _rentalEnd == null) {
      setState(() {
        _dateError = 'Wymagane daty rozpoczęcia i zakończenia najmu';
      });
      return;
    }
    if (_rentalEnd!.isBefore(_rentalStart!)) {
      setState(() {
        _dateError = 'Koniec najmu musi być późniejszy niż start';
      });
      return;
    }

    // all ok -> build property
    final prefs = await SharedPreferences.getInstance();
    final storedUserId = loggedUser!.id;
    final property = Property(
      ownerId: storedUserId!,
      name: _nameController.text.trim(),
      location: _locationController.text.trim(),
      size: double.parse(_sizeController.text.trim()),
      rooms: int.parse(_roomsController.text.trim()),
      floor: int.parse(_floorController.text.trim()),
      features: _features,
      status: _status,
      rentAmount: double.parse(_rentAmountController.text.trim()),
      depositAmount: double.parse(_depositAmountController.text.trim()),
      paymentCycle: _paymentCycleController.text.trim(),
      rentalStart: _rentalStart?.toIso8601String(),
      rentalEnd: _rentalEnd?.toIso8601String(),
    );

    Provider.of<PropertiesProvider>(context, listen: false)
        .addProperty(property, _imageFile)
        .then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mieszkanie zostało dodane.')),
        );
        Navigator.pop(context);
      }
    });
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _rentalStart = picked;
        } else {
          _rentalEnd = picked;
        }
        _dateError = null;
      });
    }
  }

  String? _validateNonEmpty(String? v, String message) {
    if (v == null || v.trim().isEmpty) return message;
    return null;
  }

  String? _validateDouble(String? v, String emptyMsg, String formatMsg,
      {double min = 0}) {
    if (v == null || v.trim().isEmpty) return emptyMsg;
    final parsed = double.tryParse(v.trim().replaceAll(',', '.'));
    if (parsed == null) return formatMsg;
    if (parsed < min) return 'Wartość musi być >= $min';
    return null;
  }

  String? _validateInt(String? v, String emptyMsg, String formatMsg,
      {int min = 0}) {
    if (v == null || v.trim().isEmpty) return emptyMsg;
    final parsed = int.tryParse(v.trim());
    if (parsed == null) return formatMsg;
    if (parsed < min) return 'Wartość musi być >= $min';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            SingleImageUploader(
              onImageSelected: (File file) {
                setState(() {
                  _imageFile = file;
                  _imageError = false;
                });
              },
            ),
            if (_imageError)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Wymagane zdjęcie',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nazwa mieszkania'),
              validator: (value) => _validateNonEmpty(value, 'Wymagana nazwa'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Lokalizacja'),
              validator: (value) =>
                  _validateNonEmpty(value, 'Wymagana lokalizacja'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _sizeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Powierzchnia (m²)'),
              validator: (value) => _validateDouble(
                  value, 'Wymagana powierzchnia', 'Niepoprawna liczba',
                  min: 0.1),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _roomsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Liczba pokoi'),
              validator: (value) => _validateInt(
                  value, 'Wymagana liczba pokoi', 'Niepoprawna liczba',
                  min: 1),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _floorController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Piętro'),
              validator: (value) => _validateInt(
                  value, 'Wymagane piętro', 'Niepoprawna liczba',
                  min: 0),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _status,
              items: ['wolne', 'wynajęte']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _status = value!;
                });
              },
              decoration: const InputDecoration(labelText: 'Status'),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Wybierz status' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _rentAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Kwota czynszu'),
              validator: (value) => _validateDouble(
                  value, 'Wymagana kwota czynszu', 'Niepoprawna liczba',
                  min: 0),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _depositAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Kwota kaucji'),
              validator: (value) => _validateDouble(
                  value, 'Wymagana kwota kaucji', 'Niepoprawna liczba',
                  min: 0),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _paymentCycleController,
              decoration: const InputDecoration(
                  labelText: 'Cykl płatności (np. miesięczny)'),
              validator: (value) =>
                  _validateNonEmpty(value, 'Wymagany cykl płatności'),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                      'Start najmu: ${_rentalStart != null ? DateFormat('yyyy-MM-dd').format(_rentalStart!) : 'Nie wybrano'}'),
                ),
                TextButton(
                  onPressed: () => _pickDate(context, true),
                  child: const Text('Wybierz'),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                      'Koniec najmu: ${_rentalEnd != null ? DateFormat('yyyy-MM-dd').format(_rentalEnd!) : 'Nie wybrano'}'),
                ),
                TextButton(
                  onPressed: () => _pickDate(context, false),
                  child: const Text('Wybierz'),
                )
              ],
            ),
            if (_dateError != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _dateError!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notatki'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('DODAJ MIESZKANIE'),
            ),
          ],
        ),
      ),
    );
  }
}
