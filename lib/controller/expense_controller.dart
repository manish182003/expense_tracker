import 'package:get/get.dart';
import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/services/database_service.dart';
import 'package:expense_tracker/services/currency_service.dart';

class ExpenseController extends GetxController {
  var expenses = <Expense>[].obs;
  var isLoading = true.obs;
  var baseCurrency = 'USD'.obs;

  @override
  void onInit() {
    super.onInit();
    loadExpenses();
  }

  Future<void> loadExpenses() async {
    try {
      isLoading.value = true;
      final loadedExpenses = await DatabaseService.getAllExpenses();
      expenses.assignAll(loadedExpenses);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteExpense(Expense expense) async {
    await DatabaseService.deleteExpense(expense.id!);
    expenses.remove(expense);
    Get.snackbar('Deleted', 'Expense deleted successfully');
  }

  Future<double> totalInBaseCurrency() async {
    double total = 0;
    for (var expense in expenses) {
      total += await CurrencyService.convertCurrency(
        expense.amount,
        expense.currency,
        baseCurrency.value,
      );
    }
    return total;
  }

  void changeBaseCurrency(String currency) {
    baseCurrency.value = currency;
  }
}
