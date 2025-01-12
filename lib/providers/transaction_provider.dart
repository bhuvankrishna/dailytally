import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../services/database_helper.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<AppTransaction> _transactions = [];
  DateTime _selectedMonth = DateTime.now();
  
  // Separate lists for income and expense categories
  List<String> _incomeCategories = [
    'Salary',
    'Freelance',
    'Investment',
    'Rent',
    'Other Income'
  ];
  List<String> _expenseCategories = [
    'Food',
    'Transportation', 
    'Utilities',
    'Rent',
    'Shopping',
    'Entertainment',
    'Healthcare',
    'Education',
    'Other Expense'
  ];

  List<AppTransaction> get transactions => _transactions;
  DateTime get selectedMonth => _selectedMonth;
  List<String> get incomeCategories => _incomeCategories;
  List<String> get expenseCategories => _expenseCategories;

  TransactionProvider() {
    _loadCategories();
  }

  // Load categories from SharedPreferences
  Future<void> _loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load income categories
    final savedIncomeCategories = prefs.getStringList('income_categories');
    if (savedIncomeCategories != null) {
      _incomeCategories = savedIncomeCategories;
    }

    // Load expense categories
    final savedExpenseCategories = prefs.getStringList('expense_categories');
    if (savedExpenseCategories != null) {
      _expenseCategories = savedExpenseCategories;
    }

    notifyListeners();
  }

  // Save categories to SharedPreferences
  Future<void> _saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setStringList('income_categories', _incomeCategories);
    await prefs.setStringList('expense_categories', _expenseCategories);
  }

  // Add a new category
  Future<void> addCategory(String category, String type) async {
    if (type == 'income') {
      if (!_incomeCategories.contains(category)) {
        _incomeCategories.add(category);
      }
    } else {
      if (!_expenseCategories.contains(category)) {
        _expenseCategories.add(category);
      }
    }
    await _saveCategories();
    notifyListeners();
  }

  // Remove a category
  Future<void> removeCategory(String category, String type) async {
    if (type == 'income') {
      _incomeCategories.remove(category);
    } else {
      _expenseCategories.remove(category);
    }
    await _saveCategories();
    notifyListeners();
  }

  // Edit a category
  Future<void> editCategory(String oldCategory, String newCategory, String type) async {
    if (type == 'income') {
      final index = _incomeCategories.indexOf(oldCategory);
      if (index != -1) {
        _incomeCategories[index] = newCategory;
      }
    } else {
      final index = _expenseCategories.indexOf(oldCategory);
      if (index != -1) {
        _expenseCategories[index] = newCategory;
      }
    }
    await _saveCategories();
    notifyListeners();
  }

  Future<void> fetchTransactions() async {
    _transactions = await _dbHelper.getTransactions(month: _selectedMonth);
    notifyListeners();
  }

  Future<void> addTransaction(AppTransaction transaction) async {
    await _dbHelper.insertTransaction(transaction);
    await fetchTransactions();
  }

  Future<void> updateTransaction(AppTransaction transaction) async {
    await _dbHelper.updateTransaction(transaction);
    await fetchTransactions();
  }

  Future<void> deleteTransaction(int id) async {
    await _dbHelper.deleteTransaction(id);
    await fetchTransactions();
  }

  void changeMonth(DateTime newMonth) {
    _selectedMonth = newMonth;
    fetchTransactions();
  }

  Future<Map<String, double>> getMonthlySummary() async {
    return await _dbHelper.getMonthlySummary(_selectedMonth);
  }

  List<String> getCategoriesForType(String type) {
    return type == 'income' ? _incomeCategories : _expenseCategories;
  }
}
