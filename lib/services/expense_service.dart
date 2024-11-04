import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

Future<double> getMonthlyExpenses() async {
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final endOfMonth = DateTime(now.year, now.month + 1, 0);

  final querySnapshot = await FirebaseFirestore.instance
    .collection('expenses')
    .where('date', isGreaterThanOrEqualTo: startOfMonth)
    .where('date', isLessThanOrEqualTo: endOfMonth)
    .get();

  double totalExpenses = 0;
  for (var doc in querySnapshot.docs) {
    totalExpenses += doc['amount'];
  }
  return totalExpenses;
}

Future<double> getDailyExpenses() async {
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

  final querySnapshot = await FirebaseFirestore.instance
    .collection('expenses')
    .where('date', isGreaterThanOrEqualTo: startOfDay)
    .where('date', isLessThanOrEqualTo: endOfDay)
    .get();

  double totalExpenses = 0;
  for (var doc in querySnapshot.docs) {
    totalExpenses += doc['amount'];
  }
  return totalExpenses;
}

Future<List<Map<String, dynamic>>> getHighestExpenses() async {
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final endOfMonth = DateTime(now.year, now.month + 1, 0);

  final querySnapshot = await FirebaseFirestore.instance
    .collection('expenses')
    .where('date', isGreaterThanOrEqualTo: startOfMonth)
    .where('date', isLessThanOrEqualTo: endOfMonth)
    .orderBy('amount', descending: true)
    .limit(5)
    .get();

  return querySnapshot.docs.map((doc) => doc.data()).toList();
}

Future<Map<String, double>> getExpensesByCategory() async {
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final endOfMonth = DateTime(now.year, now.month + 1, 0);

  final querySnapshot = await FirebaseFirestore.instance
      .collection('expenses')
      .where('date', isGreaterThanOrEqualTo: startOfMonth)
      .where('date', isLessThanOrEqualTo: endOfMonth)
      .get();

  Map<String, double> categoryTotals = {};
  for (var doc in querySnapshot.docs) {
    final category = doc['category'];
    final amount = (doc['amount'] as num).toDouble();
    if (categoryTotals.containsKey(category)) {
      categoryTotals[category] = categoryTotals[category]! + amount;
    } else {
      categoryTotals[category] = amount;
    }
  }

  return categoryTotals;
}

class ExpenseService {
  static Future<Map<String, Map<String, List<Map<String, dynamic>>>>> fetchMonthlyExpensesGrouped(int month) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, month, 1);
    final endOfMonth = DateTime(now.year, month + 1, 0);

    final querySnapshot = await FirebaseFirestore.instance
      .collection('expenses')
      .where('date', isGreaterThanOrEqualTo: startOfMonth)
      .where('date', isLessThanOrEqualTo: endOfMonth)
      .orderBy('date')
      .get();

    Map<String, Map<String, List<Map<String, dynamic>>>> groupedExpenses = {};

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final category = data['category'];
      final date = (data['date'] as Timestamp).toDate();
      final formattedDate = DateFormat('d MMM yyyy').format(date);

      final expenseEntry = {
        'name': data['name'],
        'amount': data['amount'],
        'date': date,
      };

      // Initialize category if not present
      if (!groupedExpenses.containsKey(category)) {
        groupedExpenses[category] = {};
      }

      // Initialize date group within category if not present
      if (!groupedExpenses[category]!.containsKey(formattedDate)) {
        groupedExpenses[category]![formattedDate] = [];
      }

      // Add expense entry to the category-date group
      groupedExpenses[category]![formattedDate]!.add(expenseEntry);
    }

    return groupedExpenses;
  }
}


