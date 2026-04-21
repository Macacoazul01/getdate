import 'dart:async';
import 'package:flutter/material.dart';
import 'package:getdate_textfield/getdate_textfield.dart';

class DateFieldController {
  DateFieldController({
    DateTime? initialValue,
    required DateTime firstDate,
    required DateTime lastDate,
    this.locale,
    this.validationDebounce = const Duration(milliseconds: 120),
    this.onChanged,
    this.onErrorChanged,
    this.config = const DateOverlayConfig(),
    String Function(DateError)? messageOf,
  })  : _first = firstDate,
        _last = lastDate,
        _messageOf = messageOf ?? defaultMessageOf {
    valueListenable.value = initialValue;
  }

  DateTime _first;
  DateTime _last;
  final Locale? locale;

  TextEditingController? _textController;
  FocusNode? _focusNode;
  LayerLink? _link;
  OverlayEntry? _entry;
  GlobalKey? _targetKey;
  Function? onPickComplete;

  final Duration validationDebounce;
  Timer? _debounce;

  ValueChanged<DateTime?>? onChanged;
  ValueChanged<String?>? onErrorChanged;
  final DateOverlayConfig config;
  final String Function(DateError) _messageOf;

  final ValueNotifier<DateTime?> valueListenable = ValueNotifier<DateTime?>(
    null,
  );
  final ValueNotifier<String?> errorListenable = ValueNotifier<String?>(null);
  final ValueNotifier<bool> overlayOpenListenable = ValueNotifier<bool>(false);

  bool _justSubmitted = false;

  DateTime get firstDate => _first;
  DateTime get lastDate => _last;
  DateTime? get value => valueListenable.value;
  String get text => _text();
  String? get errorText => errorListenable.value;
  bool get isOverlayOpen => overlayOpenListenable.value;

  void attach(
    TextEditingController textController,
    FocusNode focusNode,
    LayerLink link,
    GlobalKey targetKey,
  ) {
    _textController = textController;
    _focusNode = focusNode;
    _link = link;
    _targetKey = targetKey;

    _syncTextFromValue();

    _focusNode?.removeListener(_onFocusChanged);
    _focusNode?.addListener(_onFocusChanged);
  }

  void detach() {
    _focusNode?.removeListener(_onFocusChanged);
    _closeOverlayInternal();
    _debounce?.cancel();
    _focusNode?.unfocus();
    _textController = null;
    _focusNode = null;
    _link = null;
    _targetKey = null;
  }

  void dispose() {
    detach();
    valueListenable.dispose();
    errorListenable.dispose();
    overlayOpenListenable.dispose();
  }

  void setRange({required DateTime first, required DateTime last}) {
    _first = first;
    _last = last;
    validateNow();
  }

  void setValue(DateTime? dt) {
    _setValueAndNotify(dt, syncText: true);
    _clearError();
  }

  void setFinishFunction(Function? onFinishFunction) {
    onPickComplete = onFinishFunction;
  }

  void setText(String raw) {
    _writeText(raw);
    _scheduleValidation();
  }

  void onUserChangedText(String _) => _scheduleValidation();

  DateTime? validateNow() {
    _debounce?.cancel();
    return _validateInternal();
  }

  void handleSubmit() {
    final dt = validateNow();

    if (dt == null) {
      return;
    }

    _closeOverlayInternal();

    _justSubmitted = true;
    _focusNode?.unfocus();
    onPickComplete?.call();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _justSubmitted = false;
    });
  }

  void openOverlay(BuildContext context) =>
      _openOverlayInternal(context: context);
  void closeOverlay() => _closeOverlayInternal();

  void pick(DateTime dt) {
    final clamped = clampDate(dt, _first, _last);
    _setValueAndNotify(clamped, syncText: true);
    _clearError();
    _closeOverlayInternal();
    onPickComplete?.call();
  }

  void _onFocusChanged() {
    final node = _focusNode;
    if (node == null) {
      return;
    }
    if (!node.hasFocus) {
      return;
    }
    if (_justSubmitted) {
      return;
    }

    final ctx = node.context;
    if (ctx == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openOverlayInternal(context: ctx);
    });
  }

  void _syncTextFromValue() {
    _writeText(formatPtBr(valueListenable.value));
  }

  void _scheduleValidation() {
    _debounce?.cancel();
    _debounce = Timer(validationDebounce, _validateInternal);
  }

  DateTime? _validateInternal() {
    final dt = parsePtBr(_text());
    final res = validateTextPtBr(
      dt,
      first: _first,
      last: _last,
      messageOf: _messageOf,
    );

    if (res == null) {
      if (dt != null && (value == null || compareYMD(dt, value!) != 0)) {
        _setValueAndNotify(dt, syncText: false);
      }
      _clearError();
    } else {
      _setErrorAndNotify(res.message);
    }
    return dt;
  }

  void _setValueAndNotify(DateTime? dt, {required bool syncText}) {
    final current = valueListenable.value;
    final changed = !(current == null && dt == null) &&
        !(current != null && dt != null && compareYMD(current, dt) == 0);
    if (changed) {
      valueListenable.value = dt;
      if (syncText) {
        _syncTextFromValue();
      }
      onChanged?.call(dt);
    }
  }

  void _setErrorAndNotify(String? msg) {
    if (errorListenable.value == msg) {
      return;
    }
    errorListenable.value = msg;
    onErrorChanged?.call(msg);
  }

  void _clearError() => _setErrorAndNotify(null);

  void _openOverlayInternal({BuildContext? context}) {
    if (overlayOpenListenable.value || _link == null) {
      return;
    }

    final ctx = context ?? _focusNode?.context;
    if (ctx == null) {
      return;
    }
    if (_targetKey?.currentContext == null) {
      return;
    }

    final overlay = Overlay.of(ctx);
    final RenderBox overlayBox =
        overlay.context.findRenderObject()! as RenderBox;
    final RenderBox targetBox =
        _targetKey!.currentContext!.findRenderObject()! as RenderBox;

    final Size screen = overlayBox.size;
    final Size targetSize = targetBox.size;
    final Offset targetTopLeft = targetBox.localToGlobal(
      Offset.zero,
      ancestor: overlayBox,
    );

    final double prefDx = targetTopLeft.dx;
    final double prefDyBelow = targetTopLeft.dy + targetSize.height + 4;

    final bool canOpenBelow = (screen.height - prefDyBelow) >= config.maxHeight;
    final double originDy =
        canOpenBelow ? prefDyBelow : (targetTopLeft.dy - config.maxHeight+30);

    final double dx = prefDx.clamp(0.0, screen.width - config.maxWidth);
    final double dy = originDy.clamp(0.0, screen.height - config.maxHeight);

    _entry = OverlayEntry(
      builder: (_) => DateOverlay(
        first: _first,
        last: _last,
        initial: _initialForPicker(),
        onPick: pick,
        onOutsideTap: _closeOverlayInternal,
        offset: Offset(dx, dy),
        config: config,
      ),
    );
    overlay.insert(_entry!);
    overlayOpenListenable.value = true;
  }

  void _closeOverlayInternal() {
    _entry?.remove();
    _entry = null;
    if (overlayOpenListenable.value) {
      overlayOpenListenable.value = false;
    }
  }

  DateTime _initialForPicker() {
    final base = parsePtBr(_text()) ?? valueListenable.value ?? DateTime.now();
    return clampDate(base, _first, _last);
  }

  String _text() => _textController?.text ?? '';

  void _writeText(String t) {
    final tc = _textController;
    if (tc == null) {
      return;
    }
    tc
      ..text = t
      ..selection = TextSelection.collapsed(offset: t.length);
  }
}
