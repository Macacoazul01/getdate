import 'package:getdate_textfield/getdate_textfield.dart';

/// Configuration class for the visual styling and constraints of the [DateOverlay].
///
/// This class encapsulates dimensions, elevation, and border radius to keep
/// the main widget's constructor clean and focused on behavior.
class DateOverlayConfig {
  /// Creates a visual configuration for the date overlay.
  const DateOverlayConfig({
    this.minWidth = 280.0,
    this.maxWidth = 360.0,
    this.maxHeight = 360.0,
    this.elevation = 4.0,
    this.borderRadius = 8.0,
  });

  /// The minimum width of the calendar overlay.
  final double minWidth;

  /// The maximum width of the calendar overlay.
  final double maxWidth;

  /// The maximum height of the calendar overlay.
  final double maxHeight;

  /// The z-coordinate elevation of the overlay, creating a shadow effect.
  final double elevation;

  /// The border radius applied to the corners of the overlay.
  final double borderRadius;

  /// Creates a copy of this configuration, overriding the specified fields 
  /// with new values.
  DateOverlayConfig copyWith({
    double? minWidth,
    double? maxWidth,
    double? maxHeight,
    double? elevation,
    double? borderRadius,
  }) {
    return DateOverlayConfig(
      minWidth: minWidth ?? this.minWidth,
      maxWidth: maxWidth ?? this.maxWidth,
      maxHeight: maxHeight ?? this.maxHeight,
      elevation: elevation ?? this.elevation,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }
}