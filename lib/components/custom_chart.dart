import 'package:flutter/material.dart';
import 'package:finance_tracker/components/currency_formatter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 

// Kapital untuk huruf pertama
String capitalize(String input) {
  return input.split(' ').map((str) => str[0].toUpperCase() + str.substring(1)).join(' ');
}

// Menyimpan warna kategori
Map<String, Color> categoryColors = {};

// Convert warna hex ke objek color
Color hexToColor(String hexColor) {
  final buffer = StringBuffer();
  if (hexColor.length == 6 || hexColor.length == 7) buffer.write('ff');
  buffer.write(hexColor.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

// Load warna kategori
Future<void> loadCategoryColorsFromFirebase() async {
  try {
    // Get data dari firebase
    final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('categories').get();
    
    for (var doc in snapshot.docs) {
      String categoryName = doc['name'];
      String colorHex = doc['color'] ?? "ff000000";
      categoryColors[categoryName] = hexToColor(colorHex);
    }
  } catch (e) {
    print('Error loading colors from Firebase: $e');
  }
}

// Grafik expenses
class ExpenseChart extends StatelessWidget {
  final Map<String, double> data;

  const ExpenseChart({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 500;

        return Center(
          child: isWideScreen
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPieChart(),
                    const SizedBox(width: 30),
                    _buildLegend(),
                  ],
                )
              : Column(
                  children: [
                    _buildPieChart(),
                    const SizedBox(height: 30),
                    _buildLegend(),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildPieChart() {
    return SizedBox(
      height: 200,
      width: 200,
      child: PieChart(
        PieChartData(
          sections: data.entries.map((entry) {
            final category = capitalize(entry.key);
            final color = categoryColors[category] ?? Colors.grey;
            return PieChartSectionData(
              value: entry.value,
              title: '',
              color: color,
              radius: 80,
            );
          }).toList(),
          sectionsSpace: 2,
          centerSpaceRadius: 30,
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 250),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: data.entries.map((entry) {
            final category = capitalize(entry.key);
            final color = categoryColors[category] ?? Colors.grey;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    color: color,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: category,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: ': ${CurrencyFormatter.formatCurrency(entry.value)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
