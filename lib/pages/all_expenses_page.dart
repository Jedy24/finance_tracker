import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:finance_tracker/services/expense_service.dart';
import 'package:finance_tracker/components/currency_formatter.dart';
import 'package:intl/intl.dart';

class AllExpensesPage extends StatefulWidget {
  final int month;

  const AllExpensesPage({super.key, required this.month});

  @override
  _AllExpensesPageState createState() => _AllExpensesPageState();
}

class _AllExpensesPageState extends State<AllExpensesPage> {
  late Future<Map<String, Map<String, List<Map<String, dynamic>>>>> _futureGroupedExpenses;

  @override
  void initState() {
    super.initState();
    _fetchGroupedExpenses();
  }

  Future<void> _fetchGroupedExpenses() async {
    setState(() {
      _futureGroupedExpenses = ExpenseService.fetchMonthlyExpensesGrouped(widget.month);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Expenses"),
      ),
      body: FutureBuilder<Map<String, Map<String, List<Map<String, dynamic>>>>>(
        future: _futureGroupedExpenses,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          return ListView(
            children: data.entries.map((categoryEntry) {
              final category = categoryEntry.key;
              final dateGroups = categoryEntry.value;

              double totalAmount = dateGroups.values
                  .expand((expenses) => expenses)
                  .map((expense) => expense['amount'] as double)
                  .reduce((a, b) => a + b);
              if (totalAmount <= 0) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          category.toUpperCase(),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          CurrencyFormatter.formatCurrency(totalAmount),
                          style: const TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...dateGroups.entries.map((dateEntry) {
                    final date = dateEntry.key;
                    final expenses = dateEntry.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...expenses.map((expense) {
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${expense['name']} - $date',
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.blue),
                                            onPressed: () {
                                              _showEditDialog(context, expense);
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () {
                                              _deleteExpense(expense['id']);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Text(
                                    CurrencyFormatter.formatCurrency(expense['amount']),
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        const Divider(),
                      ],
                    );
                  }).toList(),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> expense) {
    final TextEditingController nameController = TextEditingController(text: expense['name']?.toString() ?? '');
    final TextEditingController amountController = TextEditingController(
      text: CurrencyFormatter.formatCurrency(expense['amount']),
    );

    String initialDateString = '';
    if (expense['date'] is DateTime) {
      initialDateString = DateFormat('yyyy-MM-dd').format(expense['date']);
    } else if (expense['date'] is Timestamp) {
      initialDateString = DateFormat('yyyy-MM-dd').format(expense['date'].toDate());
    }

    final TextEditingController dateController = TextEditingController(text: initialDateString);

    amountController.addListener(() {
      final text = amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
      if (text.isNotEmpty) {
        final formatted = CurrencyFormatter.formatCurrency(double.parse(text));
        amountController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
      }
    });

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Expense"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Expense Name'),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Date'),
                readOnly: true,
                onTap: () async {
                  DateTime? initialDate;
                  try {
                    initialDate = DateFormat('yyyy-MM-dd').parse(dateController.text);
                  } catch (e) {
                    initialDate = DateTime.now();
                  }

                  final date = await showDatePicker(
                    context: context,
                    initialDate: initialDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (date != null) {
                    dateController.text = DateFormat('yyyy-MM-dd').format(date);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final updatedExpense = {
                    'name': nameController.text.trim(),
                    'amount': double.tryParse(amountController.text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? expense['amount'],
                    'date': Timestamp.fromDate(DateFormat('yyyy-MM-dd').parse(dateController.text.trim())),
                  };

                  await ExpenseService.updateExpense(
                    expense['id'],
                    updatedExpense,
                  );

                  if (mounted) {
                    Navigator.pop(context);
                    await _fetchGroupedExpenses();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Expense updated successfully!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Failed to update expense: $e"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _deleteExpense(String? documentId) async {
    if (documentId == null || documentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid document ID"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Expense"),
          content: const Text("Are you sure you want to delete this expense?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await ExpenseService.deleteExpense(documentId);
        await _fetchGroupedExpenses();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Expense deleted successfully!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Failed to delete expense: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
