import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/transaction_model.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../utils/theme.dart';
import '../transactions/add_transaction_screen.dart';
import 'widgets/balance_card.dart';
import 'widgets/transaction_item.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = Provider.of<DatabaseService?>(context);

    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppTheme.primaryColor)));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('SpendWise'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: () => authService.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<List<TransactionModel>>(
        stream: user.transactions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
          }

          final transactions = snapshot.data ?? [];
          double totalIncome = 0;
          double totalExpense = 0;

          for (var tx in transactions) {
            if (tx.type == TransactionType.income) {
              totalIncome += tx.amount;
            } else {
              totalExpense += tx.amount;
            }
          }

          double balance = totalIncome - totalExpense;

          return RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 1));
            },
            color: AppTheme.primaryColor,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      Container(
                        height: 100,
                        color: AppTheme.primaryColor,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
                        child: BalanceCard(
                          balance: balance,
                          income: totalIncome,
                          expense: totalExpense,
                        ),
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Transactions History',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text(
                            'View All',
                            style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (transactions.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history_rounded, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'No transactions found',
                            style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return TransactionItem(transaction: transactions[index]);
                      },
                      childCount: transactions.length,
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTransactionScreen()),
          );
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }
}
