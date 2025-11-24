import 'package:flutter/material.dart';
import 'package:luluzinhakids/widgets/custom_input.dart';

class CustomSearchBar extends StatelessWidget {
  final String hintText;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const CustomSearchBar({
    super.key,
    this.hintText = 'Buscar produtos...',
    this.onChanged,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CustomInput(
        hintText: hintText,
        prefixIcon: Icons.search,
        controller: controller,
        onChanged: onChanged,
      ),
    );
  }
}
