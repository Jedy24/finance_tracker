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
      'name': 'Bayar cicilan',
      'date': Timestamp.now(),
    });
  }

static Future<void> updateInstallmentExpense(String expenseId, double newAmount, {String? newName, Timestamp? newDate}) async {
    final expenseDoc = await FirebaseFirestore.instance
        .collection('expenses')
        .doc(expenseId)
        .get();

    if (expenseDoc.exists) {
      final originalExpenseAmount = expenseDoc['amount'];
      final originalName = expenseDoc['name'] ?? "Bayar cicilan";
      final originalDate = expenseDoc['date'];

      final installmentQuery = await FirebaseFirestore.instance
          .collection('installments')
          .where('amount', isEqualTo: originalExpenseAmount)
          .where('startDate', isEqualTo: originalDate)
          .limit(1)
          .get();

      if (installmentQuery.docs.isNotEmpty) {
        final installmentDoc = installmentQuery.docs.first;

        final updatedData = {
          'amount': newAmount,
          'name': newName ?? originalName,
          if (newDate != null) 'date': newDate,
        };

        await FirebaseFirestore.instance.collection('expenses').doc(expenseId).update(updatedData);

        final amountDifference = originalExpenseAmount - newAmount;

        await adjustRemainingInstallment(installmentDoc.id, amountDifference);
      }
    }
  }

  static Future<void> adjustRemainingInstallment(String installmentId, double amountDifference) async {
    final installmentDoc = await FirebaseFirestore.instance
        .collection('installments')
        .doc(installmentId)
        .get();

    if (!installmentDoc.exists) {
      throw Exception("Installment not found");
    }

    final data = installmentDoc.data()!;
    final remainingAmount = data['remainingAmount'];
    final balance = data['balance'];
    final originalAmount = data['amount'];

    final updatedRemainingAmount = remainingAmount + amountDifference;
    final updatedBalance = balance + amountDifference;
    final updatedAmount = originalAmount + amountDifference;

    await installmentDoc.reference.update({
      'remainingAmount': updatedRemainingAmount,
      'balance': updatedBalance,
      'amount': updatedAmount,
    });
  }
}
