import 'package:expense_tracker/controller/expense_controller.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/services/currency_service.dart';
import 'package:expense_tracker/view/screens/add_edit_expense_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExpenseListScreen extends StatelessWidget {
  final ExpenseController controller = Get.put(ExpenseController());

  ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          Obx(
            () => PopupMenuButton<String>(
              onSelected: controller.changeBaseCurrency,
              itemBuilder:
                  (_) =>
                      ['USD', 'EUR', 'GBP', 'JPY', 'INR']
                          .map(
                            (currency) => PopupMenuItem(
                              value: currency,
                              child: Text('Base: $currency'),
                            ),
                          )
                          .toList(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(controller.baseCurrency.value),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () {
              SyncService.syncWhenOnline();
              Get.snackbar('Sync', 'Syncing data...');
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Summary Card
            Padding(
              padding: const EdgeInsets.all(16),
              child: FutureBuilder<double>(
                future: controller.totalInBaseCurrency(),
                builder: (context, snapshot) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade400, Colors.blue.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Expenses',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${snapshot.data?.toStringAsFixed(2) ?? '0.00'} ${controller.baseCurrency.value}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${controller.expenses.length} expenses',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Expense List
            Expanded(
              child:
                  controller.expenses.isEmpty
                      ? const Center(
                        child: Text(
                          'No expenses yet. Tap + to add your first expense.',
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: controller.expenses.length,
                        itemBuilder: (context, index) {
                          final expense = controller.expenses[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(
                                    expense.category,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  _getCategoryIcon(expense.category),
                                  color: _getCategoryColor(expense.category),
                                ),
                              ),
                              title: Text(expense.title),
                              subtitle: Text(
                                '${expense.category} • ${expense.date.day}/${expense.date.month}/${expense.date.year}',
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${expense.amount.toStringAsFixed(2)} ${expense.currency}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (!expense.synced)
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade100,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(
                                        'Pending',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              onTap:
                                  () => Get.to(
                                    () =>
                                        AddEditExpenseScreen(expense: expense),
                                  )?.then((_) => controller.loadExpenses()),
                              onLongPress:
                                  () => _showDeleteDialog(context, expense),
                            ),
                          );
                        },
                      ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => Get.to(
              () => AddEditExpenseScreen(),
            )?.then((_) => controller.loadExpenses()),
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;
      case 'Transport':
        return Icons.directions_car;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Entertainment':
        return Icons.movie;
      case 'Health':
        return Icons.medical_services;
      case 'Education':
        return Icons.school;
      case 'Bills':
        return Icons.receipt;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return Colors.orange;
      case 'Transport':
        return Colors.blue;
      case 'Shopping':
        return Colors.pink;
      case 'Entertainment':
        return Colors.purple;
      case 'Health':
        return Colors.red;
      case 'Education':
        return Colors.green;
      case 'Bills':
        return Colors.grey;
      default:
        return Colors.teal;
    }
  }

  void _showDeleteDialog(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Delete Expense'),
            content: Text(
              'Are you sure you want to delete "${expense.title}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  controller.deleteExpense(expense);
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}
