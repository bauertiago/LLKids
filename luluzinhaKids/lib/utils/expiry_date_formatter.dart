import 'package:flutter/services.dart';

class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;
    var text = newValue.text;

    text = text.replaceAll(RegExp(r'[^0-9]'), '');

    if (text.length == 1) {
      if (int.tryParse(text)! > 1) {
        return oldValue;
      }
    }

    if (text.length >= 2) {
      final month = int.tryParse(text.substring(0, 2));
      if (month == null || month < 1 || month > 12) {
        return oldValue;
      }
    }

    if (text.length >= 2) {
      text = '${text.substring(0, 2)}/${text.substring(2)}';
    }

    if (text.length > 7) {
      text = text.substring(0, 7);
    }

    if (text.length == 7) {
      final parts = text.split('/');
      final month = int.tryParse(parts[0]);
      final year = int.tryParse(parts[1]);

      if (year == null || month == null) {
        return oldValue;
      }

      if (year < currentYear) {
        return oldValue;
      }

      if (year == currentYear && month < currentMonth) {
        return oldValue;
      }
    }

    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
