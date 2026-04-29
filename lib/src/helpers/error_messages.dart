import 'package:getdate_textfield/getdate_textfield.dart';

/// Returns an error message string based on the provided [DateError].
///
/// * [e]: The date validation error enum.
/// * [invalidDate]: Message for [DateError.invalidFormat]. Defaults to 'Data inválida'.
/// * [outOfRange]: Message for [DateError.outOfRange]. Defaults to 'Fora do intervalo'.
String defaultMessageOf(
  DateError e, {
  String invalidDate = 'Data inválida',
  String outOfRange = 'Fora do intervalo',
}) {
  switch (e) {
    case DateError.invalidFormat:
      return invalidDate;
    case DateError.outOfRange:
      return outOfRange;
  }
}
