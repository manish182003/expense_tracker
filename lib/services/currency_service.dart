// Currency Service
import 'dart:convert';

import 'package:expense_tracker/services/database_service.dart';
import 'package:expense_tracker/utils/app_env.dart';
import 'package:http/http.dart' as http;
import 'package:logger/web.dart';

class CurrencyService {
  static final String baseUrl = AppEnv.baseUrl;
  static Map<String, double> _cachedRates = {};
  static DateTime? _lastFetch;
  static final Logger logger = Logger();

  static Future<Map<String, double>> getExchangeRates(
    String baseCurrency,
  ) async {
    // Check if we have fresh cached data (within 1 hour)
    if (_cachedRates.isNotEmpty &&
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!).inHours < 1) {
      return _cachedRates;
    }

    try {
      logger.i('Fetching exchange rates for $baseCurrency');
      // final response = await http
      //     .get(
      //       Uri.parse(
      //         '$baseUrl/latest?access_key=${AppEnv.apiKey}&base=$baseCurrency',
      //       ),
      //       headers: {'Content-Type': 'application/json'},
      //     )
      //     .timeout(const Duration(seconds: 10));
      final response = await http
          .get(
            Uri.parse('$baseUrl/${AppEnv.apiKey}/latest/$baseCurrency'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));
      logger.i('Response status: ${response.statusCode}');
      logger.i('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['result'] == "success") {
          _cachedRates = (data['conversion_rates'] as Map<String, dynamic>).map(
            (key, value) =>
                MapEntry(key, double.tryParse(value.toString()) ?? 0.0),
          );
          logger.i('Fetched exchange rates: $_cachedRates');
          _lastFetch = DateTime.now();
          return _cachedRates;
        }
      }
    } catch (e) {
      logger.e('Error fetching exchange rates: $e');
    }

    // Return cached rates or default rates if API fails
    return _cachedRates.isNotEmpty
        ? _cachedRates
        : {'USD': 1.0, 'EUR': 0.85, 'GBP': 0.73, 'JPY': 110.0, 'INR': 74.5};
  }

  static Future<double> convertCurrency(
    double amount,
    String fromCurrency,
    String toCurrency,
  ) async {
    if (fromCurrency == toCurrency) return amount;

    final rates = await getExchangeRates('USD');

    // Convert to USD first if needed
    double usdAmount = amount;
    if (fromCurrency != 'USD') {
      usdAmount = amount / (rates[fromCurrency] ?? 1.0);
    }

    // Convert from USD to target currency
    if (toCurrency == 'USD') {
      return usdAmount;
    } else {
      return usdAmount * (rates[toCurrency] ?? 1.0);
    }
  }
}

class SyncService {
  static Logger logger = Logger();

  static Future<void> syncWhenOnline() async {
    Logger logger = Logger();
    logger.i("💡 Syncing expenses with server...");
    final queue = await DatabaseService.getSyncQueue();

    for (var item in queue) {
      final expenseId = item['expense_id'] as int?;
      if (expenseId == null) continue;

      final expense = await DatabaseService.getExpense(expenseId);
      if (expense == null) continue;

      try {
        switch (item['action']) {
          case 'create':
            logger.i("➡️ Syncing create for expense $expenseId");
            // call API or mock
            break;
          case 'update':
            logger.i("➡️ Syncing update for expense $expenseId");
            break;
          case 'delete':
            logger.i("➡️ Syncing delete for expense $expenseId");
            break;
        }
      } catch (e) {
        logger.e("⛔ Sync failed for expense $expenseId: $e");
      }
    }

    await DatabaseService.clearSyncQueue();
  }
}
