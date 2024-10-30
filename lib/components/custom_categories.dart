import 'package:cloud_firestore/cloud_firestore.dart';
class CustomCategories {
  List<String> _categories = [];

  Future<List<String>> getCategories() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('categories').get();
    return snapshot.docs.map((doc) => doc['name'] as String).toList();
  }

  Future<void> addNewCategory(String category) async {
    await FirebaseFirestore.instance.collection('categories').add({
      'name': category,
    });
    await loadCategories();
  }

  Future<void> addExpense(double amount, String category, DateTime date) async {
    if (category == "Installment") {
      // Add to installments collection
      await FirebaseFirestore.instance.collection('installments').add({
        'amount': amount,
        'startDate': Timestamp.fromDate(date),
        'dueDate': Timestamp.fromDate(date.add(const Duration(days: 30))),
        'isPaid': false,
      });
    } else {
      // Otherwise, add to expenses collection
      await FirebaseFirestore.instance.collection('expenses').add({
        'amount': amount,
        'category': category,
        'date': Timestamp.fromDate(date),
      });
    }
  }

  // Method untuk memuat kategori dan menyimpan ke dalam list _categories
  Future<void> loadCategories() async {
    _categories = await getCategories();
  }

  // Getter untuk mengambil kategori yang sudah dimuat
  List<String> get categories => _categories;
}

