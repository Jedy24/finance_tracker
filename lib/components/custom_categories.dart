import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
class CustomCategories {
  List<String> _categories = [];
    final CollectionReference _categoriesCollection =
      FirebaseFirestore.instance.collection('categories');

  Future<void> addNewCategory(String category, Color color) async {
    final colorHex = color.value.toRadixString(16).padLeft(8, '0');
    await _categoriesCollection.doc(category).set({
      'name': category,
      'color': colorHex,
    });
  }

  Future<List<String>> getCategories() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('categories').get();
    return snapshot.docs.map((doc) => doc['name'] as String).toList();
  }

  Future<Color?> getCategoryColor(String category) async {
    final doc = await _categoriesCollection.doc(category).get();
    if (doc.exists) {
      final colorHex = doc['color'] as String;
      return Color(int.parse(colorHex, radix: 16));
    }
    return null;
  }

  Future<void> addExpense(double amount, String category, String name, DateTime date) async {
    if (category == "Installment") {
      await FirebaseFirestore.instance.collection('installments').add({
        'name': name,
        'amount': amount,
        'startDate': Timestamp.fromDate(date),
        'dueDate': Timestamp.fromDate(date.add(const Duration(days: 30))),
        'isPaid': false,
      });
    } else {
      await FirebaseFirestore.instance.collection('expenses').add({
        'amount': amount,
        'category': category,
        'name': name,
        'date': Timestamp.fromDate(date),
      });
    }
  }

  // Load kategori dan menyimpan kedalam list_category
  Future<void> loadCategories() async {
    _categories = await getCategories();
  }

  // Mengambil kategori yang sudah dimuat
  List<String> get categories => _categories;

  Future<void> updateCategory(String oldCategory, String newCategory, Color newColor) async {
    final colorHex = newColor.value.toRadixString(16).padLeft(8, '0');
    
    if (oldCategory != newCategory) {
      await _categoriesCollection.doc(oldCategory).delete();
      await _categoriesCollection.doc(newCategory).set({
        'name': newCategory,
        'color': colorHex,
      });
    } else {
      // Jika nama sama maka hanya update warna
      await _categoriesCollection.doc(oldCategory).update({
        'color': colorHex,
      });
    }
  }

  // Hapus kategori berdasarkan nama
  Future<void> deleteCategory(String category) async {
    await _categoriesCollection.doc(category).delete();
  }
}

