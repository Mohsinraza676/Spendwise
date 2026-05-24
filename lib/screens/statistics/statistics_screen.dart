import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/transaction_model.dart';
import '../../services/database_service.dart';
import '../../utils/theme.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService?>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: db == null
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
          : StreamBuilder<List<TransactionModel>>(
              stream: db.transactions,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
                }

                final transactions = snapshot.data ?? [];
                final expenses = transactions.where((t) => t.type == TransactionType.expense).toList();

                if (expenses.isEmpty) {
                  return const Center(child: Text('Add transactions to see analytics'));
                }

                Map<String, double> categoryData = {};
                double totalExpense = 0;
                for (var e in expenses) {
                  categoryData[e.category] = (categoryData[e.category] ?? 0) + e.amount;
                  totalExpense += e.amount;
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Spending Summary',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        height: 250,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: PieChart(
                          PieChartData(
                            sections: _getSections(categoryData),
                            sectionsSpace: 2,
                            centerSpaceRadius: 50,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Categories',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                      ),
                      const SizedBox(height: 12),
                      ...categoryData.entries.map((entry) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(entry.key),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w500)),
                              const Spacer(),
                              Text(
                                'Rs. ${entry.value.toStringAsFixed(0)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
    );
  }

  List<PieChartSectionData> _getSections(Map<String, double> data) {
    return data.entries.map((entry) {
      return PieChartSectionData(
        color: _getCategoryColor(entry.key),
        value: entry.value,
        title: '',
        radius: 20,
      );
    }).toList();
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food': return Colors.orange;
      case 'Travel': return Colors.blue;
      case 'Bills': return Colors.red;
      case 'Shopping': return Colors.purple;
      case 'Salary': return AppTheme.primaryColor;
      default: return Colors.grey;
    }
  }
}
