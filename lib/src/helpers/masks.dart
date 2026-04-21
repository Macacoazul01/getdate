import 'package:flutter/services.dart';

/// A [TextInputFormatter] that automatically applies a Brazilian Portuguese
/// date mask ('DD/MM/YYYY') as the user types.
///
/// It restricts the input to numbers, limits the total length to 8 digits
/// (resulting in 10 characters with slashes), and automatically inserts
/// formatting slashes `/`.
class DateMaskPtBr extends TextInputFormatter {
  // Compiled once for better performance during rapid typing
  static final _digitRegex = RegExp('[^0-9]');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Strip all non-numeric characters from the incoming text
    final digits = newValue.text.replaceAll(_digitRegex, '');

    final buffer = StringBuffer();

    // Loop through the raw digits, limiting the data to 8 total digits (DDMMYYYY)
    for (var i = 0; i < digits.length && i < 8; i++) {
      buffer.write(digits[i]);

      // Insert a slash after the day (index 1) and month (index 3),
      // ensuring we don't add a trailing slash if it's the last typed digit.
      if ((i == 1 || i == 3) && i != digits.length - 1) {
        buffer.write('/');
      }
    }

    final formattedText = buffer.toString();

    // Return the new string and force the cursor to the end of the text
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
