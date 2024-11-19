import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat('#,##0', 'id_ID');

  static String formatCurrency(dynamic value) {
    if (value == null) return 'Rp. 0';

    try {
      double amount;
      if (value is int) {
        amount = value.toDouble();
      } else if (value is double) {
        amount = value;
      } else if (value is String) {
        amount = double.parse(value.replaceAll(',', '').replaceAll('Rp.', '').trim());
      } else {
        return 'Rp. 0';
      }

      return 'Rp. ${_formatter.format(amount)}';
    } catch (e) {
      return 'Rp. 0';
    }
  }

  static double parseCurrency(String formattedValue) {
    try {
      return double.parse(formattedValue.replaceAll(',', '').replaceAll('Rp.', '').trim());
    } catch (e) {
      return 0;
    }
  }
}
