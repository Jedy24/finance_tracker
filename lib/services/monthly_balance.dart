import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_tracker/services/expense_service.dart';

class MonthlyBalanceService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _monthlyCollection = _firestore.collection('monthly');
  static final CollectionReference _expensesCollection = _firestore.collection('expenses');

  // Mengambil budget bulanan
  static Future<double> getMonthlyBalance() async {
    try {
      DocumentSnapshot doc = await _monthlyCollection.doc('thupwoBKWSiPrBL7YQ7K').get();
      
      if (doc.exists) {
        final dynamic balance = doc.get('balance');
        if (balance is num) {
          return balance.toDouble();
        }
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // Total pengeluaran bulanan
  static Future<double> getCurrentMonthExpenses() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final querySnapshot = await _expensesCollection
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .where('date', isLessThanOrEqualTo: endOfMonth)
          .get();

      double total = 0;
      for (var doc in querySnapshot.docs) {
        total += (doc.data() as Map<String, dynamic>)['amount'] as double;
      }
      
      return total;
    } catch (e) {
      return 0;
    }
  }

  // Perhitungan akhir budget
  static Future<double> fetchBalance() async {
    try {
      final monthlyExpenses = await getMonthlyExpenses();
      final currentBalance = await getMonthlyBalance();
      return currentBalance - monthlyExpenses;
    } catch (e) {
      print('Error fetching balance: $e');
      return 0;
    }
  }

  // Update budget bulanan
  static Future<bool> updateMonthlyBalance(double newBalance) async {
    try {
      await _monthlyCollection.doc('thupwoBKWSiPrBL7YQ7K').set({
        'balance': newBalance,
      });
      return true;
    } catch (e) {
      print('Error updating balance: $e');
      return false; 
    }
  }
  
}