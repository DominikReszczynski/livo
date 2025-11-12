import 'package:cas_house/main.dart';
import 'package:cas_house/main_global.dart';
import 'package:cas_house/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final success = await userProvider.login(
      email: _usernameCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HelloButton()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email or password is incorrect'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    // Circle sizes relative to device
    final big = width * 0.9;
    final medium = width * 0.6;
    final small = width * 0.55;

    return Scaffold(
      backgroundColor: LivoColors.background,
      body: Stack(
        children: [
          // ---- Decorative circles (background) ----
          Positioned(
            top: -big * 0.6,
            left: -big * 0.30,
            child: _circle(big, LivoColors.brandGold),
          ),
          Positioned(
            top: -medium * 0.6,
            right: -medium * 0.25,
            child: _circle(medium, LivoColors.brandBeige),
          ),
          Positioned(
            bottom: -medium * 0.5,
            left: -medium * 0.1,
            child: _circle(medium * 1, LivoColors.brandBeige),
          ),
          Positioned(
            bottom: -small * 0.8,
            right: -small * 0.4,
            child: _circle(small * 1.5, LivoColors.brandGold),
          ),

          // ---- Foreground content ----
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      _logoWordmark(),
                      const SizedBox(height: 36),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _roundedField(
                              controller: _usernameCtrl,
                              label: 'Username',
                              textInputAction: TextInputAction.next,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Enter your username'
                                  : null,
                            ),
                            const SizedBox(height: 18),
                            _roundedField(
                              controller: _passwordCtrl,
                              label: 'Password',
                              obscureText: _obscure,
                              keyboardType: TextInputType.visiblePassword,
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'Enter your password'
                                  : null,
                              suffix: IconButton(
                                tooltip: _obscure
                                    ? 'Show password'
                                    : 'Hide password',
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                                icon: Icon(_obscure
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  foregroundColor: LivoColors.brandGold,
                                ),
                                onPressed: () {
                                  // TODO: connect your "forgot password" flow
                                },
                                child: const Text(
                                  'Forgot your password?',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            _primaryButton(
                              label: 'Login',
                              onPressed: () {
                                if (_formKey.currentState?.validate() ??
                                    false) {
                                  _handleLogin();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      const _DividerLine(),
                      const SizedBox(height: 22),
                      const Center(
                        child: Text(
                          "Don't have an account yet?",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _primaryButton(
                        label: 'Registration',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const RegistrationScreen()),
                          );
                        },
                      ),
                      SizedBox(height: height * 0.08),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- UI pieces ----

  Widget _circle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _logoWordmark() {
    return Center(
      child: Image.asset(
        'assets/images/livo_logo.webp',
        height: 50,
      ),
    );
  }

  Widget _roundedField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    Widget? suffix,
    bool obscureText = false,
    TextInputAction? textInputAction,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      textInputAction: textInputAction,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: LivoColors.card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: LivoColors.brandGold, width: 1.2),
        ),
        suffixIcon: suffix,
      ),
    );
  }

  Widget _primaryButton(
      {required String label, required VoidCallback onPressed}) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: LivoColors.brandGold,
          foregroundColor: Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        child: Text(label),
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        return Container(
          width: c.maxWidth,
          height: 1,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          color: Colors.black.withOpacity(0.55),
        );
      },
    );
  }
}

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final success = await userProvider.register(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        nickname: _usernameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim());

    print('czy jest success ' + success.toString());
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully. Please log in.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data was incorrect or user already exists'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final big = width * 0.9;
    final medium = width * 0.6;
    final small = width * 0.55;

    return Scaffold(
      backgroundColor: LivoColors.background,
      body: Stack(
        children: [
          Positioned(
            top: -big * 0.6,
            left: -big * 0.30,
            child: _circle(big, LivoColors.brandGold),
          ),
          Positioned(
            top: -medium * 0.6,
            right: -medium * 0.25,
            child: _circle(medium, LivoColors.brandBeige),
          ),
          Positioned(
            bottom: -medium * 0.5,
            left: -medium * 0.1,
            child: _circle(medium * 1, LivoColors.brandBeige),
          ),
          Positioned(
            bottom: -small * 0.8,
            right: -small * 0.4,
            child: _circle(small * 1.5, LivoColors.brandGold),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      const _BackButtonRow(),
                      const SizedBox(height: 12),
                      _logoWordmark(),
                      const SizedBox(height: 32),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _roundedField(
                              controller: _usernameCtrl,
                              label: 'Username',
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Required'
                                  : null,
                            ),
                            const SizedBox(height: 14),
                            _roundedField(
                              controller: _emailCtrl,
                              label: 'Email',
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Required';
                                final ok =
                                    RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v);
                                return ok ? null : 'Enter a valid email';
                              },
                            ),
                            _roundedField(
                              controller: _phoneCtrl,
                              label: 'Phone',
                              keyboardType: TextInputType.phone,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty)
                                  return 'Required';
                                final compact =
                                    v.trim().replaceAll(RegExp(r'[ \-()]'), '');

                                // z prefiksem + (E.164): + i 7–15 cyfr
                                if (compact.startsWith('+')) {
                                  return RegExp(r'^\+\d{7,15}$')
                                          .hasMatch(compact)
                                      ? null
                                      : 'Enter a valid phone';
                                }

                                // bez + : 9–15 cyfr łącznie
                                final digits =
                                    compact.replaceAll(RegExp(r'\D'), '');
                                return (digits.length >= 9 &&
                                        digits.length <= 15)
                                    ? null
                                    : 'Enter a valid phone';
                              },
                            ),
                            const SizedBox(height: 14),
                            _roundedField(
                              controller: _passwordCtrl,
                              label: 'Password',
                              obscureText: _obscure1,
                              validator: (v) => (v == null || v.length < 6)
                                  ? 'Min 6 characters'
                                  : null,
                              suffix: IconButton(
                                onPressed: () =>
                                    setState(() => _obscure1 = !_obscure1),
                                icon: Icon(_obscure1
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                              ),
                            ),
                            const SizedBox(height: 14),
                            _roundedField(
                              controller: _confirmCtrl,
                              label: 'Confirm password',
                              obscureText: _obscure2,
                              validator: (v) => (v == _passwordCtrl.text)
                                  ? null
                                  : 'Passwords do not match',
                              suffix: IconButton(
                                onPressed: () =>
                                    setState(() => _obscure2 = !_obscure2),
                                icon: Icon(_obscure2
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                              ),
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    _handleRegister();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Creating account...')),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: LivoColors.brandGold,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                  textStyle: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700),
                                ),
                                child: const Text('Create account'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );

  Widget _logoWordmark() {
    return Center(
      child: Image.asset(
        'assets/images/livo_logo.webp',
        height: 50,
      ),
    );
  }

  Widget _roundedField({
    required TextEditingController controller,
    required String label,
    String? Function(String?)? validator,
    Widget? suffix,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: LivoColors.card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: LivoColors.brandGold, width: 1.2),
        ),
        suffixIcon: suffix,
      ),
    );
  }
}

class _BackButtonRow extends StatelessWidget {
  const _BackButtonRow();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back),
        style: IconButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.all(10),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
