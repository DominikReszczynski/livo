import 'package:flutter/material.dart';

class PillTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;
  final bool obscureText;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final double borderRadius;
  final EdgeInsetsGeometry contentPadding;
  final Color? fillColor;
  final List<BoxShadow>? boxShadow;

  const PillTextFormField({
    super.key,
    required this.controller,
    this.hintText,
    this.validator,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.textInputAction,
    this.focusNode,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.borderRadius = 20,
    this.contentPadding =
        const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    this.fillColor,
    this.boxShadow = const [
      BoxShadow(
        blurRadius: 8,
        offset: Offset(0, 2),
        color: Color(0x14000000),
      ),
    ],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color effectiveFill =
        fillColor ?? theme.colorScheme.surface; // ładnie działa w light/dark

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: boxShadow,
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        onChanged: onChanged,
        keyboardType: keyboardType,
        obscureText: obscureText,
        textInputAction: textInputAction,
        focusNode: focusNode,
        enabled: enabled,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: effectiveFill,
          isDense: true,
          contentPadding: contentPadding,
          // brak labelText -> czysty „pill”
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: theme.colorScheme.primary.withOpacity(.35),
              width: 1.2,
            ),
          ),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
        ),
      ),
    );
  }
}
