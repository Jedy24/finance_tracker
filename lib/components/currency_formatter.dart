import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat('#,###', 'id_ID');

  static String formatCurrency(dynamic value) {
    if (value == null) return 'Rp. 0';

    double amount;
    if (value is int) {
      amount = value.toDouble();
    } else if (value is double) {
      amount = value;
    } else {
      return 'Rp. 0';
    }

    return 'Rp. ${_formatter.format(amount)}';
  }
}
