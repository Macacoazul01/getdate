import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:getdate_textfield/getdate_textfield.dart';

/// A builder function to customize the [InputDecoration] of the [DateField].
///
/// Allows complete control over the visual appearance of the text field based
/// on its current state and validation errors.
typedef DateFieldDecorationBuilder =
    InputDecoration Function(
      BuildContext context,
      String? errorText,
      TextEditingController controller,
    );

/// A highly customizable date input field that coordinates with a
/// [DateFieldController] to validate input and display a calendar overlay.
class DateField extends StatefulWidget {
  const DateField({
    super.key,
    required this.controller,
    this.onFinishFunction,
    this.enabled = true,
    this.keyboardType = TextInputType.datetime,
    this.textInputAction = TextInputAction.done,
    this.decorationBuilder,
    this.decorationConfig = const DateFieldDecorationConfig(),
  });

  /// The controller that manages the state, validation, and overlay of this field.
  final DateFieldController controller;

  /// Callback executed when the user submits a valid date (e.g., via Enter/Tab).
  final Function? onFinishFunction;

  /// Whether the text field is interactive.
  final bool enabled;

  /// The type of keyboard to display. Defaults to [TextInputType.datetime].
  final TextInputType keyboardType;

  /// The action button on the keyboard (e.g., Done, Next).
  final TextInputAction textInputAction;

  /// Optional builder to fully customize the input decoration.
  final DateFieldDecorationBuilder? decorationBuilder;

  /// Configuration for the default built-in decoration.
  final DateFieldDecorationConfig decorationConfig;

  @override
  State<DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<DateField> {
  late final TextEditingController _textController;
  late final FocusNode _focusNode;
  late final List<TextInputFormatter> _formatters;
  final GlobalKey _targetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.controller.text);
    _focusNode = FocusNode();
    _formatters = <TextInputFormatter>[
      FilteringTextInputFormatter.allow(RegExp('[0-9/]')),
      DateMaskPtBr(),
    ];

    widget.controller.attach(_textController, _focusNode, _targetKey);
    // Simplified: always set it, even if null, to clear previous callbacks if needed
    widget.controller.setFinishFunction(widget.onFinishFunction);
  }

  @override
  void didUpdateWidget(covariant DateField oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reattach to the new controller if the widget is rebuilt with a different one
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.detach();
      widget.controller.attach(_textController, _focusNode, _targetKey);
    }

    // Always update the finish function to ensure it matches the current widget state
    widget.controller.setFinishFunction(widget.onFinishFunction);
  }

  @override
  void dispose() {
    widget.controller.detach();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.decorationConfig.showTitle) ...[
          Text(widget.decorationConfig.hint),
          const SizedBox(height: 15),
        ],
        OverlayPortal(
          key: _targetKey,
          controller: widget.controller.overlayPortalController,
          overlayChildBuilder: (BuildContext context) {
            return RepaintBoundary(
              child: DateOverlay(
                first: widget.controller.firstDate,
                last: widget.controller.lastDate,
                initial: widget.controller.overlayInitialDate,
                onPick: widget.controller.pick,
                onOutsideTap: widget.controller.closeOverlay,
                offset: widget.controller.overlayOffset,
                config: widget.controller.config,
              ),
            );
          },
          child: ValueListenableBuilder<String?>(
            valueListenable: widget.controller.errorListenable,
            builder: (context, error, _) {
              final decoration = (widget.decorationBuilder != null)
                  ? widget.decorationBuilder!(context, error, _textController)
                  : dateFieldDefaultDecoration(
                      context,
                      errorText: error,
                      controller: _textController,
                      config: widget.decorationConfig,
                    );

              return Focus(
                onKeyEvent: (node, event) {
                  if (event is KeyDownEvent) {
                    // Submit the date when Enter or Tab is pressed
                    if (event.logicalKey == LogicalKeyboardKey.enter ||
                        event.logicalKey == LogicalKeyboardKey.tab) {
                      widget.controller.handleSubmit();
                      return KeyEventResult.handled;
                    }
                    // Close the calendar overlay when Escape is pressed while typing
                    if (event.logicalKey == LogicalKeyboardKey.escape) {
                      widget.controller.closeOverlay();
                      node.unfocus();
                      return KeyEventResult.handled;
                    }
                  }
                  return KeyEventResult.ignored;
                },
                child: SizedBox(
                  height: widget.decorationConfig.height,
                  width: widget.decorationConfig.width,
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    enabled: widget.enabled,
                    keyboardType: widget.keyboardType,
                    textInputAction: widget.textInputAction,
                    inputFormatters: _formatters,
                    decoration: decoration,
                    style: TextStyle(
                      fontSize: widget.decorationConfig.fontSize,
                    ),
                    onChanged: widget.controller.onUserChangedText,
                    onSubmitted: (_) => widget.controller.handleSubmit(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
