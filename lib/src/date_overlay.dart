import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:getdate_textfield/getdate_textfield.dart';

/// A widget that displays a calendar date picker positioned as an overlay.
///
/// It listens for outside taps or the 'Escape' key to dismiss itself,
/// and returns the selected date via the [onPick] callback.
class DateOverlay extends StatelessWidget {
  /// Creates a date overlay widget.
  const DateOverlay({
    super.key,
    required this.first,
    required this.last,
    required this.initial,
    required this.onPick,
    required this.onOutsideTap,
    required this.offset,
    required this.config,
  });

  /// The earliest selectable date in the calendar.
  final DateTime first;

  /// The latest selectable date in the calendar.
  final DateTime last;

  /// The initially selected date when the calendar is opened.
  final DateTime initial;

  /// Callback executed when a date is selected by the user.
  final ValueChanged<DateTime> onPick;

  /// Callback executed when the user taps outside the calendar or presses 'Escape'.
  final VoidCallback onOutsideTap;

  /// The exact screen coordinates where the overlay should be drawn.
  final Offset offset;

  /// The visual and layout configuration for the overlay.
  final DateOverlayConfig config;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Invisible layer to detect taps outside the calendar overlay
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onOutsideTap,
        ),
        Positioned(
          left: offset.dx,
          top: offset.dy,
          child: Material(
            elevation: config.elevation,
            borderRadius: BorderRadius.circular(config.borderRadius),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: config.minWidth,
                maxWidth: config.maxWidth,
                maxHeight: config.maxHeight,
              ),
              child: Focus(
                // Listen for keyboard events, specifically closing the overlay on 'Escape'
                onKeyEvent: (node, event) {
                  if (event is KeyDownEvent &&
                      event.logicalKey == LogicalKeyboardKey.escape) {
                    onOutsideTap();
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                },
                child: CalendarDatePicker(
                  initialDate: initial,
                  firstDate: first,
                  lastDate: last,
                  onDateChanged: onPick,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
