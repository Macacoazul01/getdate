/// Defines the types of errors that can occur during date validation.
enum DateError { invalidFormat, outOfRange }

/// Parses a Brazilian Portuguese date string ('DD/MM/YYYY') into a [DateTime].
///
/// Returns `null` if the string length is not exactly 10, if the slashes are 
/// missing/misplaced, or if the resulting date is mathematically invalid 
/// (e.g., February 30th).
DateTime? parsePtBr(String text) {
  final s = text.trim();
  if (s.length != 10) {
    return null;
  }
  if (s.codeUnitAt(2) != 47 || s.codeUnitAt(5) != 47) {
    return null;
  }

  final d = int.tryParse(s.substring(0, 2));
  final mo = int.tryParse(s.substring(3, 5));
  final y = int.tryParse(s.substring(6, 10));
  if (d == null || mo == null || y == null) {
    return null;
  }
  if (mo < 1 || mo > 12 || d < 1 || d > 31) {
    return null;
  }

  final dt = DateTime(y, mo, d);
  if (dt.year != y || dt.month != mo || dt.day != d) {
    return null;
  }
  return dt;
}

/// Formats a [DateTime] object into a Brazilian Portuguese string ('DD/MM/YYYY').
///
/// Returns an empty string if [dt] is null. 
/// Pads days, months, and years with leading zeros if necessary.
String formatPtBr(DateTime? dt) {
  if (dt == null) {
    return '';
  }
  String two(int x) => x < 10 ? '0$x' : '$x';
  return '${two(dt.day)}/${two(dt.month)}/${dt.year}';
}

/// Restricts a [DateTime] [value] to stay within the [first] and [last] bounds.
///
/// If [value] is before [first], returns [first].
/// If [value] is after [last], returns [last].
/// Otherwise, returns the original [value].
DateTime clampDate(DateTime value, DateTime first, DateTime last) {
  if (value.isBefore(first)) {
    return first;
  }
  if (value.isAfter(last)) {
    return last;
  }
  return value;
}

/// Checks if a [DateTime] [value] falls inclusively between [first] and [last].
bool isInRange(DateTime value, DateTime first, DateTime last) {
  return !value.isBefore(first) && !value.isAfter(last);
}

/// Validates a parsed [DateTime] against formatting rules and a permitted range.
///
/// Returns a Record containing the [DateError] and its corresponding localized 
/// string message via the [messageOf] callback. 
/// Returns `null` if the date is perfectly valid.
({DateError error, String message})? validateTextPtBr(
  DateTime? dt, {
  required DateTime first,
  required DateTime last,
  required String Function(DateError) messageOf,
}) {
  if (dt == null) {
    return (
      error: DateError.invalidFormat,
      message: messageOf(DateError.invalidFormat),
    );
  }
  if (!isInRange(dt, first, last)) {
    return (
      error: DateError.outOfRange,
      message: messageOf(DateError.outOfRange),
    );
  }
  return null;
}

/// Compares two [DateTime] objects considering only their Year, Month, and Day.
///
/// Ignores hours, minutes, seconds, and milliseconds.
/// Returns a negative integer if [a] is earlier, positive if [a] is later, 
/// and `0` if they represent the exact same calendar day.
int compareYMD(DateTime a, DateTime b) {
  if (a.year != b.year) {
    return a.year.compareTo(b.year);
  }
  if (a.month != b.month) {
    return a.month.compareTo(b.month);
  }
  return a.day.compareTo(b.day);
}
