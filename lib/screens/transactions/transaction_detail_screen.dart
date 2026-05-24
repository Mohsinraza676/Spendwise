import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/transaction_model.dart';
import '../../services/database_service.dart';
import '../../utils/theme.dart';

class TransactionDetailScreen extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService?>(context);
    final isIncome = transaction.type == TransactionType.income;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Details'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.errorColor, size: 22),
              onPressed: () => _showDeleteDialog(context, db),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                _getCategoryIcon(transaction.category),
                size: 48,
                color: _getCategoryColor(transaction.category),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              transaction.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: isIncome ? AppTheme.successColor : AppTheme.errorColor,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Category', transaction.category, Icons.category_outlined),
                  const Divider(height: 32),
                  _buildDetailRow('Date', DateFormat('EEEE, MMM d, y').format(transaction.date), Icons.calendar_today_rounded),
                  const Divider(height: 32),
                  _buildDetailRow('Time', DateFormat('hh:mm a').format(transaction.date), Icons.access_time_rounded),
                  const Divider(height: 32),
                  _buildDetailRow('Type', isIncome ? 'Income' : 'Expense', Icons.swap_vert_rounded),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppTheme.textSecondary),
        ),
        const SizedBox(width: 16),
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15, fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context, DatabaseService? db) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Delete record?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('This action cannot be undone. Do you want to remove this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep it', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              if (db != null) {
                await db.deleteTransaction(transaction.id);
                if (context.mounted) {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to dashboard
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: AppTheme.errorColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food': return const Color(0xFFF59E0B);
      case 'Travel': return const Color(0xFF3B82F6);
      case 'Bills': return const Color(0xFFEF4444);
      case 'Shopping': return const Color(0xFF8B5CF6);
      case 'Salary': return const Color(0xFF10B981);
      default: return AppTheme.primaryColor;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food': return Icons.restaurant_rounded;
      case 'Travel': return Icons.directions_car_rounded;
      case 'Bills': return Icons.receipt_long_rounded;
      case 'Shopping': return Icons.shopping_bag_rounded;
      case 'Salary': return Icons.payments_rounded;
      default: return Icons.category_rounded;
    }
  }
}
