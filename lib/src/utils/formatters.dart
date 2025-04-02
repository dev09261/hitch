import 'package:flutter/services.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    final text = newValue.text;

    // Remove any non-digit characters
    final digitsOnly = text.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length > 10) {
      return oldValue; // Return old value if more than 10 digits
    }

    String formattedText = '';

    if (digitsOnly.length >= 3) {
      formattedText = '${digitsOnly.substring(0, 3)} ';
    } else {
      formattedText = digitsOnly;
    }

    if (digitsOnly.length > 3 && digitsOnly.length >= 6) {
      formattedText += '${digitsOnly.substring(3, 6)} ';
    } else if (digitsOnly.length > 3) {
      formattedText += digitsOnly.substring(3);
    }

    if (digitsOnly.length > 6) {
      formattedText += digitsOnly.substring(6, digitsOnly.length);
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
