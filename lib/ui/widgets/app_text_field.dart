import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final String? Function(String?)? validator;
  final TextInputAction? action;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;

  // TAMBAHAN
  final TextStyle? labelStyle;
  final TextStyle? textStyle;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.obscure = false,
    this.validator,
    this.action,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.labelStyle,   // tambahan
    this.textStyle,    // tambahan
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      textInputAction: action ?? TextInputAction.next,
      keyboardType: keyboardType,
      validator: validator,
      style: textStyle, // pakai textStyle
      decoration: InputDecoration(
        labelText: label,
        labelStyle: labelStyle, // pakai labelStyle
        border: const OutlineInputBorder(),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
