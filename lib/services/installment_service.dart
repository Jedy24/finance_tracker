import 'package:cloud_firestore/cloud_firestore.dart';

class InstallmentService {
  // Menghitung total cicilan
  static Future<double> calculateTotalInstallment() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('installments')
        .where('isPaid', isEqualTo: false) 
        .get();

    double totalInstallment = 0.0;
    for (var doc in querySnapshot.docs) {
      totalInstallment += doc['amount'];
    }
    return totalInstallment;
  }

  // Fungsi untuk membayar cicilan dan memasukkannya kedalam pengeluaran bulanan
  static Future<void> payInstallment(double amount) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('installments')
        .where('isPaid', isEqualTo: false) 
        .get();

    double remainingAmount = amount;
    for (var doc in querySnapshot.docs) {
      final currentAmount = doc['amount'];
      if (remainingAmount >= currentAmount) {
        remainingAmount -= currentAmount;
        await doc.reference.update({'amount': 0.0, 'isPaid': true});

        await _logExpense(currentAmount);
      } else {
        await doc.reference.update({'amount': currentAmount - remainingAmount});
        await _logExpense(remainingAmount);
        break;
      }
    }
  }

  static Future<void> _logExpense(double amount) async {
    await FirebaseFirestore.instance.collection('expenses').add({
      'amount': amount,
      'category': 'Installment',
      'date': Timestamp.now(),
    });
  }
}
