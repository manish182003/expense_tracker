// Database Service
import 'dart:convert';

import 'package:expense_tracker/models/expense.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _database;
  static const String expensesTable = 'expenses';
  static const String syncQueueTable = 'sync_queue';

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'expense_tracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $expensesTable(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            amount REAL NOT NULL,
            currency TEXT NOT NULL,
            category TEXT NOT NULL,
            date TEXT NOT NULL,
            synced INTEGER DEFAULT 0,
            action TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE $syncQueueTable(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            expense_id INTEGER,
            action TEXT NOT NULL,
            data TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  static Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(expensesTable);
    return List.generate(maps.length, (i) => Expense.fromJson(maps[i]));
  }

  static Future<int> insertExpense(Expense expense) async {
    final db = await database;
    expense.action = 'create';
    final id = await db.insert(expensesTable, expense.toJson());
    expense.id = id; // Set the ID for the expense object
    expense.synced = false; // Mark as unsynced
    await _addToSyncQueue(id, 'create', expense);
    return id;
  }

  static Future<void> updateExpense(Expense expense) async {
    if (expense.id == null) {
      throw Exception("Cannot update expense: id is null");
    }
    final db = await database;
    expense.action = 'update';
    await db.update(
      expensesTable,
      expense.toJson(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
    expense.synced = false; // Mark as unsynced
    await _addToSyncQueue(expense.id!, 'update', expense);
  }

  static Future<void> deleteExpense(int id) async {
    final db = await database;
    final expense = await getExpense(id);

    if (expense != null) {
      await db.delete(expensesTable, where: 'id = ?', whereArgs: [id]);
      await _addToSyncQueue(id, 'delete', expense);
    }
  }

  static Future<Expense?> getExpense(int id) async {
    final db = await database;
    final maps = await db.query(
      expensesTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Expense.fromJson(maps.first);
    }
    return null;
  }

  static Future<void> _addToSyncQueue(
    int expenseId,
    String action,
    Expense expense,
  ) async {
    final db = await database;
    await db.insert(syncQueueTable, {
      'expense_id': expenseId,
      'action': action,
      'data': jsonEncode(expense.toJson()),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<List<Map<String, dynamic>>> getSyncQueue() async {
    final db = await database;
    return await db.query(syncQueueTable, orderBy: 'created_at ASC');
  }

  static Future<void> clearSyncQueue() async {
    final db = await database;
    await db.delete(syncQueueTable);
  }
}
