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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, 
                      color: Theme.of(context).iconTheme.color
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DashboardScreen()),
                      );
                    },
                  ),
                  Text(
                    "Back",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
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
                  color: Theme.of(context).textTheme.headlineLarge?.color,
                ),
              ),

              Card(
                color: Theme.of(context).scaffoldBackgroundColor,
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
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit,
                              color: Theme.of(context).iconTheme.color
                            ),
                            onPressed: () async {
                              double currentBalance = await MonthlyBalanceService.getMonthlyBalance();

                              final TextEditingController controller = TextEditingController(
                                text: CurrencyFormatter.formatCurrency(currentBalance).replaceAll('Rp. ', ''),
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
                                      onChanged: (value) {
                                        String rawValue = value.replaceAll(RegExp(r'[^0-9]'), '');

                                        if (rawValue.isNotEmpty) {
                                          double parsedValue = double.tryParse(rawValue) ?? 0;
                                          String formattedValue = CurrencyFormatter.formatCurrency(parsedValue).replaceAll('Rp. ', '');

                                          controller.value = TextEditingValue(
                                            text: formattedValue,
                                            selection: TextSelection.collapsed(offset: formattedValue.length),
                                          );
                                        }
                                      },
                                    ),
                                    actions: [
                                      TextButton(
                                        child: const Text("Cancel"),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                      TextButton(
                                        child: const Text("Save"),
                                        onPressed: () {
                                          final rawText = controller.text.replaceAll(RegExp(r'[Rp.\s,]'), '').trim();
                                          final newValue = double.tryParse(rawText) ?? 0;
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
                        CircularProgressIndicator(
                          color: Theme.of(context).primaryColor,
                        ),
                      const SizedBox(height: 32),
                      Text(
                        'JEVON IVANDER JUANDY',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Divider(
                        color: Theme.of(context).dividerColor,
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
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  );
                  }

                  final data = snapshot.data!;
                  return ExpenseChart(data: data); 
                },
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Detail History",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.headlineMedium?.color,
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
                    child: Text(
                      "See All",
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
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
                    return CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    );
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}',
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    );
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
                          style: TextStyle(
                            color: Theme.of(context).textTheme.titleLarge?.color,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              expense['name'],
                              style: TextStyle(
                                fontSize: 15,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                            ),
                            Text(
                              DateFormat('d MMM yyyy').format(expense['date'].toDate()),
                              style: TextStyle(
                                fontSize: 15,
                                color: isDark ?  const Color(0xFF8E8E93) :  const Color(0xFF8E8E93),
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