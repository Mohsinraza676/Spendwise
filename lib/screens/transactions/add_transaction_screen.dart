import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/transaction_model.dart';
import '../../services/database_service.dart';
import '../../utils/theme.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  
  TransactionType type = TransactionType.expense;
  String category = 'Food';
  DateTime date = DateTime.now();
  bool loading = false;

  final List<String> expenseCategories = ['Food', 'Travel', 'Bills', 'Shopping', 'Other'];
  final List<String> incomeCategories = ['Salary', 'Gift', 'Investment', 'Other'];

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User?>(context);
    final db = Provider.of<DatabaseService?>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Add Transaction'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Type',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Expense')),
                      selected: type == TransactionType.expense,
                      onSelected: (val) => setState(() {
                        type = TransactionType.expense;
                        category = expenseCategories[0];
                      }),
                      selectedColor: AppTheme.errorColor.withOpacity(0.1),
                      labelStyle: TextStyle(
                        color: type == TransactionType.expense ? AppTheme.errorColor : AppTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Income')),
                      selected: type == TransactionType.income,
                      onSelected: (val) => setState(() {
                        type = TransactionType.income;
                        category = incomeCategories[0];
                      }),
                      selectedColor: AppTheme.successColor.withOpacity(0.1),
                      labelStyle: TextStyle(
                        color: type == TransactionType.income ? AppTheme.successColor : AppTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                'Details',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  hintText: 'Amount',
                  prefixIcon: Icon(Icons.attach_money_rounded, color: AppTheme.primaryColor),
                ),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Enter an amount';
                  if (double.tryParse(val) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'Description',
                  prefixIcon: Icon(Icons.edit_note_rounded, color: AppTheme.primaryColor),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Enter a title' : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: category,
                decoration: const InputDecoration(
                  hintText: 'Category',
                  prefixIcon: Icon(Icons.category_rounded, color: AppTheme.primaryColor),
                ),
                items: (type == TransactionType.expense ? expenseCategories : incomeCategories)
                    .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (val) => setState(() => category = val!),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    setState(() => date = pickedDate);
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    hintText: 'Date',
                    prefixIcon: Icon(Icons.calendar_today_rounded, color: AppTheme.primaryColor),
                  ),
                  child: Text(DateFormat('EEEE, MMM d, y').format(date)),
                ),
              ),
              const SizedBox(height: 48),
              if (loading)
                const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
              else
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate() && user != null && db != null) {
                      setState(() => loading = true);
                      try {
                        final double amount = double.parse(_amountController.text);
                        await db.addTransaction(TransactionModel(
                          id: '',
                          userId: user.uid,
                          title: _titleController.text,
                          amount: amount,
                          type: type,
                          category: category,
                          date: date,
                        ));
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Transaction saved successfully!')),
                          );
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        setState(() => loading = false);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to save: $e'), backgroundColor: AppTheme.errorColor),
                          );
                        }
                      }
                    }
                  },
                  child: const Text('Save Transaction'),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
