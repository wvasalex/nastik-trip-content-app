import 'package:intl/intl.dart';
export 'colors.dart';
export 'fs.dart';

class Helpers {
  static pluralize(int n, {String one, String two, String many}) {
    n %= 100;
    if (n >= 5 && n <= 20) {
      return many;
    }
    n %= 10;
    if (n == 1) {
      return one;
    }
    if (n >= 2 && n <= 4) {
      return two;
    }
    return many;
  }

  static String currency(double amount) {
    return NumberFormat.currency(
      symbol: 'P',
      locale: 'ru',
      decimalDigits: 0,
    ).format(amount);
  }

  static String date({int date, String format = 'd MMMM y, H:mm'}) {
    final DateFormat _format = DateFormat(format);
    return _format.format(DateTime.fromMillisecondsSinceEpoch(date * 1000));
  }
}
