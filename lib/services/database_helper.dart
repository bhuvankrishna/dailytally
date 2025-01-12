import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/transaction.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'dailytally_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertTransaction(AppTransaction transaction) async {
    final db = await database;
    return await db.insert(
      'transactions',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<AppTransaction>> getTransactions({DateTime? month}) async {
    final db = await database;
    
    List<Map<String, dynamic>> maps;
    if (month != null) {
      maps = await db.query(
        'transactions',
        where: 'strftime("%Y-%m", date) = ?',
        whereArgs: ['${month.year}-${month.month.toString().padLeft(2, '0')}'],
        orderBy: 'date DESC',
      );
    } else {
      maps = await db.query(
        'transactions',
        orderBy: 'date DESC',
      );
    }

    return List.generate(maps.length, (i) {
      return AppTransaction.fromMap(maps[i]);
    });
  }

  Future<int> updateTransaction(AppTransaction transaction) async {
    final db = await database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, double>> getMonthlySummary(DateTime month) async {
    final db = await database;
    
    var incomeResult = await db.query(
      'transactions',
      where: 'strftime("%Y-%m", date) = ? AND type = ?',
      whereArgs: [
        '${month.year}-${month.month.toString().padLeft(2, '0')}',
        'income'
      ],
      columns: ['SUM(amount) as total'],
    );
    
    var expenseResult = await db.query(
      'transactions',
      where: 'strftime("%Y-%m", date) = ? AND type = ?',
      whereArgs: [
        '${month.year}-${month.month.toString().padLeft(2, '0')}',
        'expense'
      ],
      columns: ['SUM(amount) as total'],
    );

    double income = (incomeResult.first['total'] as num?)?.toDouble() ?? 0.0;
    double expense = (expenseResult.first['total'] as num?)?.toDouble() ?? 0.0;

    return {
      'income': income,
      'expense': expense,
      'balance': income - expense,
    };
  }
}
