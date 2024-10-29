import 'package:finance_tracker/components/currency_formatter.dart';
import 'package:finance_tracker/services/installment_service.dart';
import 'package:finance_tracker/services/monthly_balance.dart';

class PaymentService {
  static String formatCurrency(String value) {
    if (value.isEmpty) return '';
    final onlyNumbers = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (onlyNumbers.isEmpty) return '';
    final amount = double.parse(onlyNumbers);
    return CurrencyFormatter.formatCurrency(amount);
  }

  static Future<double> loadBalance() async {
    return await MonthlyBalanceService.fetchBalance();
  }

  static Future<double> calculateRemainingInstallment() async {
    return await InstallmentService.calculateTotalInstallment();
  }

  static Future<void> payInstallment(double amount) async {
    await InstallmentService.payInstallment(amount);
  }
}