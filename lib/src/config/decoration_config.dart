import 'package:flutter/material.dart';
import 'package:getdate_textfield/getdate_textfield.dart';

/// Configuration class for styling a Date text field.
///
/// This class holds various properties to customize the appearance and
/// behavior of the [InputDecoration] applied to the date field.
class DateFieldDecorationConfig {
  /// Creates a configuration for the date field decoration.
  const DateFieldDecorationConfig({
    this.forceHeight = true,
    this.blockError = false,
    this.showTitle = true,
    this.showHint = false,
    this.hint = '',
    this.radius = 10,
    this.noBorder = false,
    this.clear = false,
    this.padding,
    this.fontSize,
    this.onClear,
    this.width,
    this.height,
    this.colors = const DateFieldColors(),
  });

  final bool forceHeight;
  final bool blockError;
  final bool showTitle;
  final bool showHint;
  final String hint;
  final double radius;
  final bool noBorder;
  final bool clear;
  final EdgeInsetsGeometry? padding;
  final double? fontSize;
  final VoidCallback? onClear;
  final double? width;
  final double? height;
  
  /// The color palette used for this decoration.
  final DateFieldColors colors;

  /// Creates a copy of this configuration, overriding the specified fields.
  DateFieldDecorationConfig copyWith({
    bool? forceHeight,
    bool? blockError,
    bool? showTitle,
    bool? showHint,
    String? hint,
    double? radius,
    bool? noBorder,
    bool? clear,
    EdgeInsetsGeometry? padding,
    double? fontSize,
    VoidCallback? onClear,
    double? width,
    double? height,
    DateFieldColors? colors,
  }) {
    return DateFieldDecorationConfig(
      forceHeight: forceHeight ?? this.forceHeight,
      blockError: blockError ?? this.blockError,
      showTitle: showTitle ?? this.showTitle,
      showHint: showHint ?? this.showHint,
      hint: hint ?? this.hint,
      radius: radius ?? this.radius,
      noBorder: noBorder ?? this.noBorder,
      clear: clear ?? this.clear,
      padding: padding ?? this.padding,
      fontSize: fontSize ?? this.fontSize,
      onClear: onClear ?? this.onClear,
      width: width ?? this.width,
      height: height ?? this.height,
      colors: colors ?? this.colors,
    );
  }
}


/// Generates a default [InputDecoration] for a date field based on the provided configuration.
InputDecoration dateFieldDefaultDecoration(
  BuildContext context, {
  required String? errorText,
  required TextEditingController controller,
  required DateFieldDecorationConfig config,
}) {
  final palette = config.colors;

  /// Helper function to generate an [OutlineInputBorder] with a specific color.
  OutlineInputBorder buildBorder(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(config.radius),
        borderSide: config.noBorder
            ? const BorderSide(style: BorderStyle.none)
            : BorderSide(color: color),
      );

  return InputDecoration(
    hoverColor: palette.hoverColor,
    fillColor: palette.fillColor,
    filled: true,
    isDense: !config.forceHeight,
    contentPadding: config.padding ?? const EdgeInsets.fromLTRB(10, 8, 10, 8),
    
    // Hides the error text visually while keeping its state active if forced.
    errorStyle: (config.forceHeight || config.blockError)
        ? const TextStyle(fontSize: 0.001)
        : null,
    errorText: errorText,
    errorMaxLines: 3,

    labelStyle: TextStyle(color: palette.labelColor, fontSize: config.fontSize),
    hintText: config.showHint ? config.hint : null,
    hintStyle: TextStyle(color: palette.hintColor, fontSize: 14),

    focusedBorder: buildBorder(palette.focusedBorderColor),
    errorBorder: buildBorder(palette.errorBorderColor),
    focusedErrorBorder: buildBorder(palette.errorBorderColor),
    enabledBorder: buildBorder(palette.enabledBorderColor),
    disabledBorder: buildBorder(palette.disabledBorderColor),

    suffixIcon: config.clear
        ? Material(
            type: MaterialType.transparency,
            child: InkWell(
              canRequestFocus: false,
              borderRadius: const BorderRadius.all(Radius.circular(24)),
              onTap: () {
                controller.clear();
                config.onClear?.call();
              },
              child: Icon(Icons.clear, color: palette.clearIconColor, size: 20),
            ),
          )
        : null,
  );
}