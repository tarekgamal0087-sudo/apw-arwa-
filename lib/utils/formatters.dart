import 'package:intl/intl.dart';

class Formatters {
  /// تنسيق السعر بالجنيه المصري، مثال: 275.00 -> "275 ج.م"
  static String currency(double value) {
    final formatted = NumberFormat('#,##0.##', 'en').format(value);
    return '$formatted ج.م';
  }

  static String date(DateTime date) {
    return DateFormat('yyyy/MM/dd - hh:mm a').format(date);
  }
}
