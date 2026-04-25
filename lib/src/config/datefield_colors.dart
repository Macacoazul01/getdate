import 'package:flutter/material.dart';

/// Configuration class for styling the colors of a Date text field.
///
/// This allows developers to easily override default colors without
/// having to build a completely custom [InputDecoration] from scratch.
class DateFieldColors {
  /// Creates a color palette for the date field.
  const DateFieldColors({
    this.fillColor = white,
    this.hoverColor = almostWhite,
    this.focusedBorderColor = blue,
    this.errorBorderColor = red,
    this.enabledBorderColor = Colors.transparent,
    this.disabledBorderColor = Colors.grey,
    this.hintColor = blue,
    this.labelColor = Colors.grey,
    this.clearIconColor = Colors.grey,
  });

  // Default color constants used internally.
  static const red = Color.fromARGB(255, 198, 0, 0);
  static const almostWhite = Color.fromARGB(255, 250, 250, 250);
  static const blue = Color.fromARGB(255, 0, 102, 255);
  static const white = Color.fromARGB(255, 255, 255, 255);
  static const hintGray = Color.fromARGB(255, 169, 169, 169);
  static const borderGray = Color.fromARGB(255, 163, 163, 163);

  /// The background color of the text field.
  final Color fillColor;

  /// The background color of the text field when hovered by a mouse pointer.
  final Color hoverColor;

  /// The color of the border when the text field has input focus.
  final Color focusedBorderColor;

  /// The color of the border when the text field is in an error state.
  final Color errorBorderColor;

  /// The color of the border when the text field is enabled but not focused.
  final Color enabledBorderColor;

  /// The color of the border when the text field is disabled.
  final Color disabledBorderColor;

  /// The color of the hint text (placeholder) inside the text field.
  final Color hintColor;

  /// The color of the main text and standard icons (like the calendar icon).
  final Color labelColor;

  /// The color of the clear icon ('X' button) when the field is clearable.
  final Color clearIconColor;

  /// Creates a copy of this color configuration with the given fields replaced.
  DateFieldColors copyWith({
    Color? fillColor,
    Color? hoverColor,
    Color? focusedBorderColor,
    Color? errorBorderColor,
    Color? enabledBorderColor,
    Color? disabledBorderColor,
    Color? hintColor,
    Color? labelColor,
    Color? clearIconColor,
  }) {
    return DateFieldColors(
      fillColor: fillColor ?? this.fillColor,
      hoverColor: hoverColor ?? this.hoverColor,
      focusedBorderColor: focusedBorderColor ?? this.focusedBorderColor,
      errorBorderColor: errorBorderColor ?? this.errorBorderColor,
      enabledBorderColor: enabledBorderColor ?? this.enabledBorderColor,
      disabledBorderColor: disabledBorderColor ?? this.disabledBorderColor,
      hintColor: hintColor ?? this.hintColor,
      labelColor: labelColor ?? this.labelColor,
      clearIconColor: clearIconColor ?? this.clearIconColor,
    );
  }
}
