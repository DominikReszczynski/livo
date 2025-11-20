import 'package:cas_house/main_global.dart';
import 'package:cas_house/widgets/pill_text_from_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:intl/intl.dart';
import 'package:cas_house/providers/properties_provider.dart';

class AddNewPropertyTenant extends StatefulWidget {
  const AddNewPropertyTenant({
    super.key,
    required this.propertiesProvider,
  });

  final PropertiesProvider propertiesProvider;

  @override
  State<AddNewPropertyTenant> createState() => _AddNewPropertyTenantState();
}

class _AddNewPropertyTenantState extends State<AddNewPropertyTenant> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _propertyID = TextEditingController();

  String _pin = '';
  bool _submitted = false;

  DateTime? _rentalStart;
  DateTime? _rentalEnd;
  String? _dateError;

  final DateFormat dateFmt = DateFormat('dd.MM.yyyy');

  @override
  void initState() {
    super.initState();
    _propertyID.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _propertyID.dispose();
    super.dispose();
  }

  /// wybór daty — true = start, false = end
  Future<void> _pickDate(bool isStart) async {
    final initialDate = isStart
        ? (_rentalStart ?? DateTime.now())
        : (_rentalEnd ?? DateTime.now().add(const Duration(days: 30)));

    final DateTime? picked = await showDatePicker(
      context: context,
      useRootNavigator: true,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      // locale: const Locale('pl', 'PL'),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _rentalStart = picked;
        } else {
          _rentalEnd = picked;
        }

        // walidacja logiczna
        if (_rentalStart != null &&
            _rentalEnd != null &&
            _rentalEnd!.isBefore(_rentalStart!)) {
          _dateError = "Data zakończenia nie może być przed rozpoczęciem.";
        } else {
          _dateError = null;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    setState(() => _submitted = true);

    final isFormValid = _formKey.currentState!.validate();
    final isPinValid = _pin.length == 5;

    if (!isFormValid || !isPinValid) return;

    if (_rentalStart == null || _rentalEnd == null) {
      setState(() => _dateError = "Podaj obie daty wynajmu.");
      return;
    }

    // 🧠 Wywołanie backendu przez provider
    final ok = await context.read<PropertiesProvider>().addTenantToProperty(
          _propertyID.text.trim(),
          _pin,
          _rentalStart!,
          _rentalEnd!,
        );

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Najemca został dodany.')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Center(child: Text('Wystąpił błąd!')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _propertyID.text.trim().isNotEmpty && _pin.length == 5;

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(
          children: [
            // 🔹 ID mieszkania
            PillTextFormField(
              controller: _propertyID,
              hintText: 'ID mieszkania',
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Wymagane ID mieszkania'
                  : null,
              prefixIcon: const Icon(Icons.home_outlined),
            ),
            const SizedBox(height: 16),

            // 🔹 PIN właściciela
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('PIN właściciela',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 8),

            PinCodeTextField(
              appContext: context,
              length: 5,
              obscureText: false,
              animationType: AnimationType.fade,
              keyboardType: TextInputType.number,
              enableActiveFill: true,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(8),
                fieldHeight: 66,
                fieldWidth: 58,
                activeFillColor: Colors.white,
                selectedFillColor: Colors.grey.shade100,
                inactiveFillColor: Colors.grey.shade100,
                activeColor: LivoColors.brandGold,
                selectedColor: Colors.grey,
                inactiveColor: LivoColors.brandGold,
              ),
              animationDuration: const Duration(milliseconds: 250),
              onChanged: (val) => setState(() => _pin = val),
              onCompleted: (_) => _submitForm(),
            ),

            if (_submitted && _pin.length != 5)
              const Padding(
                padding: EdgeInsets.only(top: 6.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Wymagany 5-cyfrowy PIN',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // 🔹 Daty wynajmu
            Card(
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
                      child: Text(
                        'Daty wynajmu',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                      ),
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

            const SizedBox(height: 24),

            // 🔹 przycisk
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: canSubmit ? _submitForm : null,
                style: FilledButton.styleFrom(
                  backgroundColor: LivoColors.brandGold,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('DODAJ MIESZKANIE'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 💠 Pomocniczy widget do wyboru dat
class _DatePill extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DatePill({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(fontSize: 15),
        ),
      ),
    );
  }
}
