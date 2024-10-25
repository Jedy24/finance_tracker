import 'package:cloud_firestore/cloud_firestore.dart';

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
