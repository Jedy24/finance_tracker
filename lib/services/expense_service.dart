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
  static Future<Map<String, Map<String, List<Map<String, dynamic>>>>> fetchMonthlyExpensesGrouped(
      int month, {
      DateTime? startDate,
      DateTime? endDate,
      String? category,
    }) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, month, 1);
    final endOfMonth = DateTime(now.year, month + 1, 0);

    Query query = FirebaseFirestore.instance.collection('expenses');

    // Filter berdasarkan bulan
    if (startDate == null && endDate == null) {
      query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth));
      query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth));
    }

    // Filter berdasarkan rentang waktu
    if (startDate != null) {
      query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }
    if (endDate != null) {
      query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    // Filter berdasarkan kategori
    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }

    try {
      final querySnapshot = await query.orderBy('date').get();
      Map<String, Map<String, List<Map<String, dynamic>>>> groupedExpenses = {};

      for (var doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        final category = data['category'] ?? 'Uncategorized';
        final date = (data['date'] as Timestamp?)?.toDate() ?? DateTime.now();
        final formattedDate = DateFormat('d MMM yyyy').format(date);

        final expenseEntry = {
          'id': doc.id,
          'name': data['name'] ?? 'Unknown',
          'amount': (data['amount'] as num?)?.toDouble() ?? 0.0,
          'date': date,
        };

        groupedExpenses.putIfAbsent(category, () => {});
        groupedExpenses[category]!.putIfAbsent(formattedDate, () => []);
        groupedExpenses[category]![formattedDate]!.add(expenseEntry);
      }
      return groupedExpenses;
    } catch (e) {
      throw Exception("Error fetching data: $e");
    }
  }

  static Future<void> updateExpense(String documentId, Map<String, dynamic> updatedData) async {
    await FirebaseFirestore.instance
        .collection('expenses')
        .doc(documentId)
        .update(updatedData);
  }

  static Future<void> deleteExpense(String documentId) async {
    await FirebaseFirestore.instance
        .collection('expenses')
        .doc(documentId)
        .delete();
  }
}