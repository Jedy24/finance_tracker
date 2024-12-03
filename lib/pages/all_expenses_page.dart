import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance_tracker/services/installment_service.dart';
import 'package:flutter/material.dart';
import 'package:finance_tracker/services/expense_service.dart';
import 'package:finance_tracker/components/currency_formatter.dart';
import 'package:finance_tracker/components/custom_categories.dart';
import 'package:intl/intl.dart';

class AllExpensesPage extends StatefulWidget {
  final int month;

  const AllExpensesPage({super.key, required this.month});

  @override
  _AllExpensesPageState createState() => _AllExpensesPageState();
}

class _AllExpensesPageState extends State<AllExpensesPage> {
  late Future<Map<String, Map<String, List<Map<String, dynamic>>>>> _futureGroupedExpenses;
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedCategory;
  final CustomCategories _customCategories = CustomCategories();

  late TextEditingController _startDateController;
  late TextEditingController _endDateController;

  @override
  void initState() {
    super.initState();
    _customCategories.loadCategories();
    _startDateController = TextEditingController(
      text: _startDate != null ? DateFormat('yyyy-MM-dd').format(_startDate!) : "",
    );
    _endDateController = TextEditingController(
      text: _endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : "",
    );
    _fetchGroupedExpenses();
  }

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  Future<void> _fetchGroupedExpenses() async {
    setState(() {
      _futureGroupedExpenses = ExpenseService.fetchMonthlyExpensesGrouped(
        widget.month,
        startDate: _startDate,
        endDate: _endDate,
        category: _selectedCategory,
      );
    });
  }

  Widget _buildFilterButton() {
    return IconButton(
      icon: const Icon(Icons.filter_list, color: Colors.white),
      onPressed: _showFilterDialog,
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        DateTime? tempStartDate = _startDate;
        DateTime? tempEndDate = _endDate;
        String? tempSelectedCategory = _selectedCategory;

        return AlertDialog(
          title: const Text("Filter Expenses"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: tempSelectedCategory,
                isExpanded: true,
                decoration: const InputDecoration(labelText: "Category"),
                hint: const Text("Select Category"),
                items: _customCategories.categories
                    .map((category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ))
                    .toList(),
                onChanged: (value) {
                  tempSelectedCategory = value;
                },
              ),
              const SizedBox(height: 10.0),
              TextField(
                readOnly: true,
                controller: _startDateController,
                decoration: const InputDecoration(labelText: "Start Date"),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: tempStartDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (date != null) {
                    setState(() {
                      tempStartDate = date;
                      _startDateController.text = DateFormat('yyyy-MM-dd').format(date);
                    });
                  }
                },
              ),
              const SizedBox(height: 10.0),
              TextField(
                readOnly: true,
                controller: _endDateController,
                decoration: const InputDecoration(labelText: "End Date"),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: tempEndDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (date != null) {
                    setState(() {
                      tempEndDate = date;
                      _endDateController.text = DateFormat('yyyy-MM-dd').format(date);
                    });
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
              onPressed: () {
                setState(() {
                  _selectedCategory = tempSelectedCategory;
                  _startDate = tempStartDate;
                  _endDate = tempEndDate;
                });
                Navigator.pop(context);
                _fetchGroupedExpenses();
              },
              child: const Text("Apply"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedCategory = null;
                  _startDate = null;
                  _endDate = null;
                  _startDateController.clear();
                  _endDateController.clear();
                });
                Navigator.pop(context);
                _fetchGroupedExpenses();
              },
              child: const Text("Reset"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "All Expenses",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 28,
          ),
        ),
        actions: [_buildFilterButton()],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF12B0F8), Color(0xFF007AFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<Map<String, Map<String, List<Map<String, dynamic>>>>>(
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
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Map<String, dynamic> expense) {
    final TextEditingController nameController = TextEditingController(text: expense['name']?.toString() ?? '');
    final TextEditingController amountController = TextEditingController(
      text: CurrencyFormatter.formatCurrency(expense['amount']), 
    );
    final FocusNode amountFocusNode = FocusNode();

    String initialDateString = '';
    if (expense['date'] is DateTime) {
      initialDateString = DateFormat('yyyy-MM-dd').format(expense['date']);
    } else if (expense['date'] is Timestamp) {
      initialDateString = DateFormat('yyyy-MM-dd').format(expense['date'].toDate());
    }

    final TextEditingController dateController = TextEditingController(text: initialDateString);

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
                focusNode: amountFocusNode,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    String numericValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                    
                    if (numericValue.isNotEmpty) {
                      double amount = double.parse(numericValue);
                      amountController.text = CurrencyFormatter.formatCurrency(amount);
                      amountController.selection = TextSelection.fromPosition(
                        TextPosition(offset: amountController.text.length),
                      );
                    }
                  }
                },
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
                  final rawAmountText = amountController.text.replaceAll(RegExp(r'[^0-9]'), '');
                  final updatedAmount = rawAmountText.isEmpty ? 
                      expense['amount'] : 
                      double.parse(rawAmountText);

                  if (expense['category'] == 'Installment') {
                    await InstallmentService.updateInstallmentExpense(
                      expense['id'],
                      updatedAmount,
                    );
                  } else {
                    final updatedExpense = {
                      'name': nameController.text.trim(),
                      'amount': updatedAmount,
                      'date': Timestamp.fromDate(DateFormat('yyyy-MM-dd').parse(dateController.text.trim())),
                    };
                    await ExpenseService.updateExpense(expense['id'], updatedExpense);
                  }

                  if (mounted) {
                    Navigator.pop(context);
                    await _fetchGroupedExpenses();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Expense updated successfully!",
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Failed to update expense: $e",
                          style: const TextStyle(color: Colors.white),
                        ),
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
          content: Text(
            "Invalid document ID",
            style: TextStyle(color: Colors.white),
          ),
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
              content: Text(
                "Expense deleted successfully!",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Failed to delete expense: $e",
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}