import 'dart:io';
import 'package:cas_house/main_global.dart';
import 'package:cas_house/models/properties.dart';
import 'package:cas_house/widgets/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:cas_house/providers/properties_provider.dart';

class AddNewPropertyOwner extends StatefulWidget {
  final Property? propertyToEdit;
  final PropertiesProvider propertiesProvider;

  const AddNewPropertyOwner({
    super.key,
    this.propertyToEdit,
    required this.propertiesProvider,
  });

  @override
  State<AddNewPropertyOwner> createState() => _AddNewPropertyOwnerState();
}

class _AddNewPropertyOwnerState extends State<AddNewPropertyOwner> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _sizeController = TextEditingController();
  final _roomsController = TextEditingController();
  final _floorController = TextEditingController();
  final _rentAmountController = TextEditingController();
  final _depositAmountController = TextEditingController();
  final _paymentCycleController = TextEditingController(text: 'miesięczny');
  final _notesController = TextEditingController();

  File? _imageFile;
  bool _imageError = false;

  String _status = 'wolne';
  DateTime? _rentalStart;
  DateTime? _rentalEnd;
  String? _dateError;

  final _moneyFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'^\d+([.,]\d{0,2})?$'));
  final _intFormatter = FilteringTextInputFormatter.digitsOnly;

  @override
  void initState() {
    super.initState();

    final p = widget.propertyToEdit;
    if (p != null) {
      _nameController.text = p.name;
      _locationController.text = p.location;
      _sizeController.text = p.size.toString();
      _roomsController.text = p.rooms.toString();
      _floorController.text = p.floor.toString();
      _rentAmountController.text = p.rentAmount.toStringAsFixed(2);
      _depositAmountController.text = p.depositAmount.toStringAsFixed(2);
      _paymentCycleController.text = p.paymentCycle;
      _notesController.text = p.notes ?? '';
      _status = p.status;
      if (p.rentalStart != null) {
        _rentalStart = DateTime.tryParse(p.rentalStart!);
      }
      if (p.rentalEnd != null) {
        _rentalEnd = DateTime.tryParse(p.rentalEnd!);
      }
    }
  }

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

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? (_rentalStart ?? now) : (_rentalEnd ?? now),
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _rentalStart = picked;
          if (_rentalEnd != null && _rentalEnd!.isBefore(_rentalStart!)) {
            _rentalEnd = null;
          }
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
    if (parsed < min) return 'Wartość musi być ≥ $min';
    return null;
  }

  String? _validateInt(String? v, String emptyMsg, String formatMsg,
      {int min = 0}) {
    if (v == null || v.trim().isEmpty) return emptyMsg;
    final parsed = int.tryParse(v.trim());
    if (parsed == null) return formatMsg;
    if (parsed < min) return 'Wartość musi być ≥ $min';
    return null;
  }

  Future<void> _submitForm() async {
    setState(() {
      _imageError = false;
      _dateError = null;
    });

    if (!_formKey.currentState!.validate()) return;

    // 🔹 W trybie dodawania obraz jest wymagany
    if (widget.propertyToEdit == null && _imageFile == null) {
      setState(() => _imageError = true);
      return;
    }

    // 🔹 Daty tylko przy statusie "wynajęte"
    if (_status == 'wynajęte') {
      if (_rentalStart == null || _rentalEnd == null) {
        setState(
            () => _dateError = 'Wymagane daty rozpoczęcia i zakończenia najmu');
        return;
      }
      if (_rentalEnd!.isBefore(_rentalStart!)) {
        setState(
            () => _dateError = 'Koniec najmu musi być późniejszy niż start');
        return;
      }
    }

    final property = Property(
      id: widget.propertyToEdit?.id, // 🔹 ważne przy edycji
      ownerId: loggedUser!.id!,
      name: _nameController.text.trim(),
      location: _locationController.text.trim(),
      size: double.parse(_sizeController.text.trim().replaceAll(',', '.')),
      rooms: int.parse(_roomsController.text.trim()),
      floor: int.parse(_floorController.text.trim()),
      features: const <String>[],
      status: _status,
      rentAmount:
          double.parse(_rentAmountController.text.trim().replaceAll(',', '.')),
      depositAmount: double.parse(
          _depositAmountController.text.trim().replaceAll(',', '.')),
      paymentCycle: _paymentCycleController.text.trim(),
      rentalStart: _rentalStart?.toIso8601String(),
      rentalEnd: _rentalEnd?.toIso8601String(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
    );

    bool ok = false;
    if (widget.propertyToEdit == null) {
      ok = await context
          .read<PropertiesProvider>()
          .addProperty(property, _imageFile);
    } else {
      ok = await context
          .read<PropertiesProvider>()
          .updateProperty(property, _imageFile);
    }

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.propertyToEdit == null
              ? 'Mieszkanie zostało dodane.'
              : 'Zmiany zapisano pomyślnie.'),
        ),
      );
      Navigator.pop(context);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFmt = DateFormat('yyyy-MM-dd');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // KARTA: Obraz główny
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SingleImageUploader(
                    initialImageUrl: widget.propertyToEdit?.mainImage != null
                        ? "$baseUrl/uploads/${widget.propertyToEdit!.mainImage}"
                        : null,
                    onImageSelected: (File file) => setState(() {
                      _imageFile = file;
                      _imageError = false;
                    }),
                  ),
                  if (_imageError)
                    const Padding(
                      padding: EdgeInsets.only(top: 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Wymagane zdjęcie',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // KARTA: Dane podstawowe
            Card(
              color: LivoColors.brandBeige,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const _SectionTitle('Podstawowe'),
                    const SizedBox(height: 12),
                    _PillField(
                      controller: _nameController,
                      hintText: 'Nazwa mieszkania',
                      validator: (v) => _validateNonEmpty(v, 'Wymagana nazwa'),
                      prefixIcon: const Icon(Icons.home_outlined),
                    ),
                    const SizedBox(height: 12),
                    _PillField(
                      controller: _locationController,
                      hintText: 'Lokalizacja',
                      validator: (v) =>
                          _validateNonEmpty(v, 'Wymagana lokalizacja'),
                      prefixIcon: const Icon(Icons.location_on_outlined),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _PillField(
                            controller: _sizeController,
                            hintText: 'Powierzchnia (m²)',
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [_moneyFormatter],
                            validator: (v) => _validateDouble(
                              v,
                              'Wymagana powierzchnia',
                              'Niepoprawna liczba',
                              min: 0.1,
                            ),
                            prefixIcon: const Icon(Icons.square_foot_outlined),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _PillField(
                            controller: _roomsController,
                            hintText: 'Pokoje',
                            keyboardType: TextInputType.number,
                            inputFormatters: [_intFormatter],
                            validator: (v) => _validateInt(v,
                                'Wymagana liczba pokoi', 'Niepoprawna liczba',
                                min: 1),
                            prefixIcon: const Icon(Icons.meeting_room_outlined),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _PillField(
                      controller: _floorController,
                      hintText: 'Piętro',
                      keyboardType: TextInputType.number,
                      inputFormatters: [_intFormatter],
                      validator: (v) => _validateInt(
                          v, 'Wymagane piętro', 'Niepoprawna liczba',
                          min: 0),
                      prefixIcon: const Icon(Icons.stairs_outlined),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // KARTA: Finanse i status
            Card(
              color: LivoColors.brandBeige,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const _SectionTitle('Status i finanse'),
                    const SizedBox(height: 12),

                    // Status jako pill-dropdown
                    _PillDropdown<String>(
                      value: _status,
                      items: const ['wolne', 'wynajęte'],
                      onChanged: (v) => setState(() => _status = v!),
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Wybierz status' : null,
                      icon: const Icon(Icons.flag_outlined),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _PillField(
                            controller: _rentAmountController,
                            hintText: 'Czynsz',
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [_moneyFormatter],
                            validator: (v) => _validateDouble(v,
                                'Wymagana kwota czynszu', 'Niepoprawna liczba',
                                min: 0),
                            prefixIcon: const Icon(Icons.payments_outlined),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _PillField(
                            controller: _depositAmountController,
                            hintText: 'Kaucja',
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [_moneyFormatter],
                            validator: (v) => _validateDouble(v,
                                'Wymagana kwota kaucji', 'Niepoprawna liczba',
                                min: 0),
                            prefixIcon: const Icon(Icons.savings_outlined),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    _PillField(
                      controller: _paymentCycleController,
                      hintText: 'Cykl płatności (np. miesięczny)',
                      validator: (v) =>
                          _validateNonEmpty(v, 'Wymagany cykl płatności'),
                      prefixIcon: const Icon(Icons.repeat_rounded),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // KARTA: Daty najmu (wymagane tylko dla "wynajęte")
            if (_status == 'wynajęte')
              Card(
                color: LivoColors.brandBeige,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const _SectionTitle('Daty najmu'),
                          const SizedBox(width: 8),
                          if (_status == 'wolne')
                            Text(
                              '(opcjonalnie)',
                              style: TextStyle(
                                  color: theme.textTheme.bodySmall?.color
                                      ?.withOpacity(.7)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _DatePill(
                              label: _rentalStart == null
                                  ? 'Start najmu'
                                  : dateFmt.format(_rentalStart!),
                              onTap: () => _pickDate(true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _DatePill(
                              label: _rentalEnd == null
                                  ? 'Koniec najmu'
                                  : dateFmt.format(_rentalEnd!),
                              onTap: () => _pickDate(false),
                            ),
                          ),
                        ],
                      ),
                      if (_dateError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(_dateError!,
                                style: const TextStyle(color: Colors.red)),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // KARTA: Notatki
            Card(
              color: LivoColors.brandBeige,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _PillField(
                  controller: _notesController,
                  hintText: 'Notatki',
                  maxLines: 4,
                  prefixIcon: const Icon(Icons.notes_outlined),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Submit
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submitForm,
                style: FilledButton.styleFrom(
                  backgroundColor: LivoColors.brandGold,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(widget.propertyToEdit == null
                    ? 'DODAJ MIESZKANIE'
                    : 'ZAPISZ ZMIANY'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ===== pomocnicze, lokalne „pill” widgety ===== */

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800));
  }
}

class _PillField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final FormFieldValidator<String>? validator;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon;
  final int maxLines;

  const _PillField({
    required this.controller,
    this.hintText,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.prefixIcon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon,
        filled: true,
        fillColor: theme.colorScheme.surface,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
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
              color: theme.colorScheme.primary.withOpacity(.35), width: 1.2),
        ),
      ),
    );
  }
}

class _PillDropdown<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String? Function(T?)? validator;
  final Widget? icon;

  const _PillDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DropdownButtonFormField<T>(
      value: value,
      validator: validator,
      items: items
          .map((e) => DropdownMenuItem<T>(value: e, child: Text(e.toString())))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: icon,
        filled: true,
        fillColor: theme.colorScheme.surface,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
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
              color: theme.colorScheme.primary.withOpacity(.35), width: 1.2),
        ),
      ),
    );
  }
}

class _DatePill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _DatePill({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            const Icon(Icons.event_outlined),
            const SizedBox(width: 8),
            Expanded(child: Text(label)),
            const Icon(Icons.keyboard_arrow_down_rounded),
          ],
        ),
      ),
    );
  }
}
