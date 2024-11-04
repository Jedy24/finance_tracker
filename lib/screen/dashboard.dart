import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'balance.dart';
import 'add_expenses.dart';
import 'payment.dart';
import 'package:intl/intl.dart';
import 'package:finance_tracker/services/expense_service.dart';
import 'package:finance_tracker/components/currency_formatter.dart';
import 'package:finance_tracker/components/custom_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>{
  bool _isLoadingColors = true; // Track loading state

  @override
  void initState() {
    super.initState();
    loadCategoryColorsFromFirebase().then((_) {
      setState(() {
        _isLoadingColors = false; // Set loading to false once colors are loaded
      });
    });
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      getMonthlyExpenses(),
      getDailyExpenses(),
      getExpensesByCategory(),
      getHighestExpenses(),
    ]);
    
    if (mounted) {
      setState(() {
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), 
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello',
                        style: GoogleFonts.inter(
                          textStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Home',
                            style: GoogleFonts.inter(
                              textStyle: const TextStyle(
                                color: Color(0xFF007AFF),
                                fontSize: 34,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              // Tombol Add
                              Container(
                                width: 78,
                                height: 40, 
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF12B0F8), Color(0xFF007AFF)],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => AddExpensesScreen()),
                                    );
                                  },
                                  child: Text(
                                    'Add',
                                    style: GoogleFonts.inter(
                                      textStyle: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Tombol Pay
                              Container(
                                width: 78,
                                height: 40, 
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF12B0F8), Color(0xFF007AFF)],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => PaymentScreen()),
                                    );
                                  },
                                  child: Text(
                                    'Pay',
                                    style: GoogleFonts.inter(
                                      textStyle: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    if (_isLoadingColors) 
                    const Center(child: CircularProgressIndicator()),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Total pengeluaran bulanan dan harian
                Center(
                  child: Card(
                    color: Colors.white,
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '${DateFormat.MMMM().format(DateTime.now())} Expenses',
                            style: GoogleFonts.inter(
                              textStyle: const TextStyle(
                                color: Color(0xFF007AFF), 
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 1),
                          FutureBuilder<double>(
                            future: getMonthlyExpenses(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator(); // Placeholder saat loading
                              }
                              if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              }
                              return Text(
                                CurrencyFormatter.formatCurrency(snapshot.data),
                                style: GoogleFonts.inter(
                                  textStyle: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${DateFormat('d MMM yyyy').format(DateTime.now())} Expenses',
                            style: GoogleFonts.inter(
                              textStyle: const TextStyle(
                                color: Color(0xFF007AFF),
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          FutureBuilder<double>(
                            future: getDailyExpenses(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const CircularProgressIndicator(); 
                              } else if (snapshot.hasError) {
                                return const Text('Error loading data'); 
                              } else {
                                final dailyExpense = snapshot.data ?? 0;
                                return Text(
                                  CurrencyFormatter.formatCurrency(dailyExpense), 
                                  style: GoogleFonts.inter(
                                    textStyle: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Grafik pengeluaran
                Card(
                  color: Colors.white,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expenses',
                          style: GoogleFonts.inter(
                            textStyle: const TextStyle(
                              color: Color(0xFF007AFF),
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        if (!_isLoadingColors) ...[
                          FutureBuilder<Map<String, double>>(
                            future: getExpensesByCategory(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              if (snapshot.hasError) {
                                return Center(child: Text('Error: ${snapshot.error}'));
                              }

                              final data = snapshot.data ?? {};
                              return ExpenseChart(data: data);
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Riwayat pengeluaran tertinggi dan tombol "See all"
                Card(
                  color: Colors.white,
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Highest Expenses',
                              style: GoogleFonts.inter(
                                textStyle: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 0),
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => BalancePage()),
                                  );
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  alignment: Alignment.centerRight,
                                ),
                                child: Text(
                                  'See More',
                                  style: GoogleFonts.inter(
                                    textStyle: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // History
                        FutureBuilder<List<Map<String, dynamic>>>(
                          future: getHighestExpenses(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }
                            final expenses = snapshot.data?.take(3).toList() ?? [];
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
                                  subtitle: Text(
                                    DateFormat('d MMM yyyy').format(expense['date'].toDate()),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF8E8E93),
                                    ),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

