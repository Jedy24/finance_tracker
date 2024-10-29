import 'package:cloud_firestore/cloud_firestore.dart';

class InstallmentService {
  static Future<double> calculateTotalInstallment() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('expenses')
        .where('category', isEqualTo: 'Installment')
        .get();

    double totalInstallment = 0.0;
    for (var doc in querySnapshot.docs) {
      totalInstallment += doc['amount'];
    }
    return totalInstallment;
  }

  static Future<void> payInstallment(double amount) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('expenses')
        .where('category', isEqualTo: 'Installment')
        .get();

    // Reduce the amount across all installment documents
    double remainingAmount = amount;
    for (var doc in querySnapshot.docs) {
      final currentAmount = doc['amount'];
      if (remainingAmount > currentAmount) {
        remainingAmount -= currentAmount;
        await doc.reference.update({'amount': 0.0});
      } else {
        await doc.reference.update({'amount': currentAmount - remainingAmount});
        break;
      }
    }
  }
}
