import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:luluzinhakids/extensions/context_extensions.dart';

class CustomInput extends StatelessWidget {
  final String? label;
  final bool requiredField;
  final String? hintText;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final bool hasError;
  final EdgeInsetsGeometry? contentPadding;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;

  const CustomInput({
    super.key,
    this.label,
    this.requiredField = false,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.hasError = false,
    this.contentPadding,
    this.controller,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final normalBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: context.colors.secondary),
    );

    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.red),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null && label!.isNotEmpty) ...[
          RichText(
            text: TextSpan(
              text: label,
              style: context.texts.bodyMedium,
              children: [
                if (requiredField)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: Colors.red),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
        ],

        TextField(
          controller: controller,
          onChanged: onChanged,
          onTap: onTap,
          obscureText: obscureText,
          keyboardType: keyboardType,
          readOnly: readOnly,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(prefixIcon),
            suffixIcon: suffixIcon,
            isDense: true,
            contentPadding:
                contentPadding ??
                const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            enabledBorder: hasError ? errorBorder : normalBorder,
            focusedBorder: hasError ? errorBorder : normalBorder,
            errorBorder: errorBorder,
            focusedErrorBorder: errorBorder,

            errorText: null,

            prefixIconConstraints: const BoxConstraints(
              minHeight: 20,
              minWidth: 40,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
