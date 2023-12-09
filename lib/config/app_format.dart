import 'package:intl/intl.dart';

class AppFormat {
  static String shortPrice(num number) {
    return NumberFormat.compactCurrency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(number);
  }

  static String longPrice(num number) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(number);
  }

  static String shortDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  static String fullDate(source) {
    switch (source.runtimeType) {
      case String:
        return DateFormat('EEEE, dd MMMM yyyy').format(DateTime.parse(source));
      case DateTime:
        return DateFormat('EEEE, dd MMMM yyyy').format(source);
      default:
        return 'Not valid';
    }
  }
}
