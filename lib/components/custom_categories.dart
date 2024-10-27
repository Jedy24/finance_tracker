import 'package:cloud_firestore/cloud_firestore.dart';

class CustomCategories {
  List<String> _categories = [];

  // Method untuk mengambil daftar kategori dari Firestore
  Future<List<String>> getCategories() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('categories').get();
    return snapshot.docs.map((doc) => doc['name'] as String).toList();
  }

  // Method untuk menambah kategori baru ke dalam Firestore
  Future<void> addNewCategory(String category) async {
    await FirebaseFirestore.instance.collection('categories').add({
      'name': category,
    });
    await loadCategories(); // Memperbarui daftar kategori
  }

  // Method untuk menambah pengeluaran ke dalam Firestore
  Future<void> addExpense(double amount, String category, DateTime date) async {
    await FirebaseFirestore.instance.collection('expenses').add({
      'amount': amount,
      'category': category,
      'date': Timestamp.fromDate(date),
    });
  }

  // Method untuk memuat kategori dan menyimpan ke dalam list _categories
  Future<void> loadCategories() async {
    _categories = await getCategories();
  }

  // Getter untuk mengambil kategori yang sudah dimuat
  List<String> get categories => _categories;
}
