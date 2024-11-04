import 'package:flutter/material.dart';
import 'package:finance_tracker/services/expense_service.dart'; 
import 'package:finance_tracker/components/currency_formatter.dart';

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

              double totalAmount = dateGroups.values.expand((expenses) => expenses).map((expense) => expense['amount'] as double).reduce((a, b) => a + b);
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
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
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
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 0.0),
                                  child: Text(
                                    CurrencyFormatter.formatCurrency(expense['amount']),
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
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
}