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
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

      // Inisialisasi kategori jika belum ada
      if (!groupedExpenses.containsKey(category)) {
        groupedExpenses[category] = {};
      }

      // Inisialisasi tanggal di dalam kategori jika belum ada
      if (!groupedExpenses[category]!.containsKey(formattedDate)) {
        groupedExpenses[category]![formattedDate] = [];
      }

      // Tambahkan entri pengeluaran ke dalam kelompok kategori-tanggal
      groupedExpenses[category]![formattedDate]!.add(expenseEntry);
    }

    return groupedExpenses;
  }

  // static Future<void> updateExpense(String documentId, Map<String, dynamic> updatedData) async {
  //   try {
  //     final Map<String, dynamic> dataToUpdate = {
  //       'name': updatedData['name'] ?? '',
  //       'amount': double.tryParse(updatedData['amount'].toString()) ?? 0.0,
  //       'category': updatedData['category'] ?? 'Uncategorized',
  //     };

  //     if (updatedData['date'] != null) {
  //       DateTime? date;
  //       if (updatedData['date'] is String) {
  //         try {
  //           date = DateFormat('yyyy-MM-dd').parse(updatedData['date']);
  //         } catch (e) {
  //           print('Date parsing error: $e');
  //         }
  //       } else if (updatedData['date'] is DateTime) {
  //         date = updatedData['date'];
  //       }

  //       if (date != null) {
  //         dataToUpdate['date'] = Timestamp.fromDate(date);
  //       }
  //     }

  //     await _firestore
  //         .collection('expenses')
  //         .doc(documentId)
  //         .update(dataToUpdate);
  //   } catch (e) {
  //     throw Exception('Failed to update expense: $e');
  //   }
  // }

  // static Future<void> deleteExpense(String documentId) async {
  //   try {
  //     await _firestore
  //         .collection('expenses')
  //         .doc(documentId)
  //         .delete();
  //   } catch (e) {
  //     throw Exception('Failed to delete expense: $e');
  //   }
  // }
}


