// lib/sections/user/edit_user_screen.dart
import 'package:cas_house/main_global.dart';
import 'package:cas_house/sections/user/user_section_header.dart';
import 'package:cas_house/widgets/rounded_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cas_house/providers/user_provider.dart';

class EditUserScreen extends StatefulWidget {
  const EditUserScreen({super.key});

  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;

  bool _saving = false;

  final _phoneFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'[0-9+ \-()]'));

  @override
  void initState() {
    super.initState();
    final u = context.read<UserProvider>().user;
    _usernameCtrl = TextEditingController(text: u?.username ?? '');
    _emailCtrl = TextEditingController(text: u?.email ?? '');
    _phoneCtrl = TextEditingController(text: u?.phone ?? '');
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  String? _validateNotEmpty(String? v, String msg) {
    if (v == null || v.trim().isEmpty) return msg;
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email jest wymagany';
    final ok = RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(v.trim());
    if (!ok) return 'Nieprawidłowy adres e-mail';
    return null;
  }

  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Telefon jest wymagany';

    final raw = v.trim();
    // Wywal spacje, myślniki i nawiasy do walidacji
    final compact = raw.replaceAll(RegExp(r'[ \-()]'), '');

    // Jeśli jest prefiks "+", wymagaj E.164: + i 7–15 cyfr
    if (compact.startsWith('+')) {
      if (!RegExp(r'^\+\d{7,15}$').hasMatch(compact)) {
        return 'Nieprawidłowy numer (np. +48123456789)';
      }
      return null;
    }

    // Bez "+": policz same cyfry (9–15)
    final digitsOnly = compact.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length < 9 || digitsOnly.length > 15) {
      return 'Nieprawidłowy numer (9–15 cyfr)';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      await context.read<UserProvider>().updateProfile(
            username: _usernameCtrl.text.trim(),
            email: _emailCtrl.text.trim(),
            phone:
                _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dane użytkownika zaktualizowane')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd aktualizacji: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Edycja profilu')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                UserSectionHeader(
                  username: _usernameCtrl.text,
                  email: _emailCtrl.text,
                ),
                Card(
                    color: LivoColors.brandBeige,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            PillField(
                              controller: _usernameCtrl,
                              hintText: 'Nazwa użytkownika',
                              validator: (v) => _validateNotEmpty(
                                  v, 'Wymagana nazwa użytkownika'),
                              prefixIcon: const Icon(
                                Icons.person_outline,
                              ),
                            ),
                            const SizedBox(height: 12),
                            PillField(
                              controller: _emailCtrl,
                              hintText: 'Email',
                              validator: _validateEmail,
                              prefixIcon: const Icon(
                                Icons.alternate_email,
                              ),
                            ),
                            const SizedBox(height: 12),
                            PillField(
                              controller: _phoneCtrl,
                              hintText: 'Telefon',
                              validator: _validatePhone,
                              keyboardType: TextInputType.phone,
                              prefixIcon: const Icon(
                                Icons.phone_outlined,
                              ),
                            ),
                          ],
                        ))),
                const SizedBox(height: 20),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: LivoColors.brandGold,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                      textStyle: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    child: const Text('Zapisz zmiany'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
