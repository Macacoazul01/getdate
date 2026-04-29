import 'package:flutter/material.dart';
import 'package:getdate_textfield/getdate_textfield.dart';

/// Configuration class for styling and structuring a Date text field.
///
/// This class holds various properties to customize the appearance, dimensions,
/// and behavioral layout of the [InputDecoration] applied to the date field.
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
    this.hintFontSize = 14.0,
    this.iconSize = 20.0,
    this.onClear,
    this.width,
    this.height,
    this.colors = const DateFieldColors(),
  });

  /// Whether to visually hide the error text while maintaining the error state layout.
  /// Useful to prevent the text field from changing height when an error occurs.
  final bool forceHeight;

  /// Similar to [forceHeight], hides the error text visually but keeps the error border.
  final bool blockError;

  /// Whether to display a dedicated title widget above the text field.
  final bool showTitle;

  /// Whether to display the hint text (placeholder) inside the field.
  final bool showHint;

  /// The actual text to display as a hint or title depending on configuration.
  final String hint;

  /// The circular border radius applied to the text field outline.
  final double radius;

  /// If true, removes all visible borders from the text field.
  final bool noBorder;

  /// Whether to display a trailing clear ('X') icon button to erase the input.
  final bool clear;

  /// The internal padding between the text and the field's borders.
  final EdgeInsetsGeometry? padding;

  /// The font size of the input text and labels.
  final double? fontSize;

  /// The font size specifically for the hint text.
  final double hintFontSize;

  /// The size of the trailing icons (e.g., calendar icon or clear icon).
  final double iconSize;

  /// Optional callback executed when the user taps the clear icon.
  final VoidCallback? onClear;

  /// The fixed width of the text field container. If null, it expands to fit.
  final double? width;

  /// The fixed height of the text field container. If null, it sizes based on content.
  final double? height;

  /// The color palette used to style the text field's borders, backgrounds, and text.
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
    double? hintFontSize,
    double? iconSize,
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
      hintFontSize: hintFontSize ?? this.hintFontSize,
      iconSize: iconSize ?? this.iconSize,
      onClear: onClear ?? this.onClear,
      width: width ?? this.width,
      height: height ?? this.height,
      colors: colors ?? this.colors,
    );
  }
}

/// Helper function to build the default [InputDecoration] based on the provided configuration.
///
/// This abstracts the complex logic of mapping custom [DateFieldDecorationConfig]
/// properties to standard Flutter [InputDecoration] fields.
InputDecoration dateFieldDefaultDecoration(
  BuildContext context, {
  required String? errorText,
  required TextEditingController controller,
  required DateFieldDecorationConfig config,
}) {
  final palette = config.colors;

  // Helper function to dynamically build the appropriate border based on state
  InputBorder buildBorder(Color color) => config.noBorder
      ? InputBorder.none
      : OutlineInputBorder(
          borderRadius: BorderRadius.circular(config.radius),
          borderSide: BorderSide(color: color),
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

    hintStyle: TextStyle(
      color: palette.hintColor,
      fontSize: config.hintFontSize,
    ),

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
              child: Icon(
                Icons.clear,
                color: palette.clearIconColor,
                size: config.iconSize,
              ),
            ),
          )
        : null,
  );
}
