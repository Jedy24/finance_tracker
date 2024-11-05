import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard.dart';
import 'package:finance_tracker/components/custom_chart.dart';
import 'package:finance_tracker/services/expense_service.dart';
import 'package:finance_tracker/components/currency_formatter.dart';
import 'package:finance_tracker/services/monthly_balance.dart';
import 'package:intl/intl.dart';
import 'package:finance_tracker/pages/all_expenses_page.dart';

class BalancePage extends StatefulWidget {
  const BalancePage({super.key});

  @override
  _BalancePageState createState() => _BalancePageState();
}

class _BalancePageState extends State<BalancePage> {
  double? balance;

  @override
  void initState() {
    super.initState();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    final finalBalance = await MonthlyBalanceService.fetchBalance();
    setState(() {
      balance = finalBalance;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentMonth = DateTime.now().month;
    final monthName = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'][currentMonth - 1].toUpperCase();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
             Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DashboardScreen()),
                      );
                    },
                  ),
                  const Text(
                    "Back",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              Text(
                'Wallet',
                style: GoogleFonts.inter(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'BALANCE $monthName',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () async {
                              double currentBalance = await MonthlyBalanceService.getMonthlyBalance();

                              final TextEditingController controller = TextEditingController(
                                text: currentBalance.toString(),
                              );

                              double? newBalance = await showDialog<double>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text("Edit Balance"),
                                    content: TextField(
                                      controller: controller,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        prefixText: 'Rp. ',
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        child: const Text("Cancel"),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                      TextButton(
                                        child: const Text("Save"),
                                        onPressed: () {
                                          final newValue = double.tryParse(controller.text) ?? 0;
                                          Navigator.pop(context, newValue);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                              if (newBalance != null) {
                                await MonthlyBalanceService.updateMonthlyBalance(newBalance);
                                await _loadBalance();
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      if (balance != null) ...[
                        Text(
                          CurrencyFormatter.formatCurrency(balance!),
                          style: GoogleFonts.inter(
                            fontSize: 32,
                            color: balance! >= 0 ? Colors.blue : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ] else
                        const CircularProgressIndicator(),
                      const SizedBox(height: 32),
                      Text(
                        'JEVON IVANDER JUANDY',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Divider(
                        color: Colors.grey,
                        thickness: 5,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Chart Section
              FutureBuilder<Map<String, double>>(
                future: getExpensesByCategory(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const CircularProgressIndicator();

                  final data = snapshot.data!;
                  return ExpenseChart(data: data); 
                },
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Detail History",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AllExpensesPage(month: currentMonth),
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      alignment: Alignment.centerRight,
                    ),
                    child: const Text(
                      "See All",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: getHighestExpenses(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  final expenses = snapshot.data ?? [];

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                        title: Text(
                          capitalize(expense['category']),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              expense['name'],
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              DateFormat('d MMM yyyy').format(expense['date'].toDate()),
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF8E8E93),
                              ),
                            ),
                          ],
                        ),
                        trailing: Text(
                          CurrencyFormatter.formatCurrency(expense['amount']),
                          style: const TextStyle(
                            color: Colors.blue,
                            fontSize: 17, 
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}