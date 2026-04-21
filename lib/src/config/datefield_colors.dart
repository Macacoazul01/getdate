import 'package:flutter/material.dart';

const red = Color.fromARGB(255, 198, 0, 0);
const almostWhite = Color.fromARGB(255, 250, 250, 250);
const blue = Color.fromARGB(255, 0, 102, 255);
const white = Color.fromARGB(255, 255, 255, 255);
const hintGray = Color.fromARGB(255, 169, 169, 169);
const borderGray = Color.fromARGB(255, 163, 163, 163);

/// Configuration class for styling the colors of a Date text field.
///
/// This allows developers to easily override default colors without
/// having to build a completely custom [InputDecoration].
class DateFieldColors {
  const DateFieldColors({
    this.fillColor = white,
    this.hoverColor = almostWhite,
    this.focusedBorderColor = blue,
    this.errorBorderColor = red,
    this.enabledBorderColor = Colors.transparent,
    this.disabledBorderColor = Colors.grey,
    this.hintColor = Colors.blue,
    this.labelColor = Colors.grey,
    this.clearIconColor = Colors.grey,
  });

  final Color fillColor;
  final Color hoverColor;
  final Color focusedBorderColor;
  final Color errorBorderColor;
  final Color enabledBorderColor;
  final Color disabledBorderColor;
  final Color hintColor;
  final Color labelColor;
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
