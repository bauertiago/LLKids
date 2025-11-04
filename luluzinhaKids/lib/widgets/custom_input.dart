import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final EdgeInsetsGeometry? contentPadding;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final bool readOnly;

  const CustomInput({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.contentPadding,
    this.controller,
    this.onChanged,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      obscureText: obscureText,
      keyboardType: keyboardType,
      readOnly: readOnly,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: suffixIcon,
        isDense: true,
        contentPadding:
            contentPadding ??
            const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        prefixIconConstraints: const BoxConstraints(
          minHeight: 20,
          minWidth: 40,
        ),
      ),
    );
  }
}
