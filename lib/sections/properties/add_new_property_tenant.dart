import 'package:cas_house/main_global.dart';
import 'package:cas_house/widgets/pill_text_from_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart'; // ⬅️
import 'package:cas_house/providers/properties_provider.dart';

class AddNewPropertyTenant extends StatefulWidget {
  const AddNewPropertyTenant(
      {super.key, required PropertiesProvider propertiesProvider});

  @override
  State<AddNewPropertyTenant> createState() => _AddNewPropertyTenantState();
}

class _AddNewPropertyTenantState extends State<AddNewPropertyTenant> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _propertyID = TextEditingController();
  String _pin = '';
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _propertyID.addListener(
        () => setState(() {})); // do włączania/wyłączania przycisku
  }

  @override
  void dispose() {
    _propertyID.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    setState(() => _submitted = true);

    final isFormValid = _formKey.currentState!.validate();
    final isPinValid = _pin.length == 5;

    if (!isFormValid || !isPinValid) return;

    final ok = await context
        .read<PropertiesProvider>()
        .addTenantToProperty(_propertyID.text.trim(), _pin);

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mieszkanie zostało dodane.')),
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
            // ID mieszkania
            PillTextFormField(
              controller: _propertyID,
              hintText: 'ID mieszkania',
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Wymagane ID mieszkania'
                  : null,
              prefixIcon: const Icon(Icons.home_outlined),
            ),
            const SizedBox(height: 16),

            // Etykieta PIN
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('PIN właściciela',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 8),

            // PIN 5-cyfrowy (PinCodeTextField)
            PinCodeTextField(
              appContext: context,
              length: 5,
              obscureText: false,
              animationType: AnimationType.fade,
              keyboardType: TextInputType.number,
              autoFocus: false,
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
              onCompleted: (_) =>
                  _submitForm(), // enter 5 cyfr → spróbuj wysłać
            ),

            // walidacja PINu (gdy user próbował wysłać)
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

            // przycisk
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
