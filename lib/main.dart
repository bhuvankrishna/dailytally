import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import 'providers/transaction_provider.dart';
import 'models/transaction.dart';
import 'screens/category_management_screen.dart';
import 'utils/string_extensions.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TransactionProvider(),
      child: const DailyTallyApp(),
    ),
  );
}

class DailyTallyApp extends StatelessWidget {
  const DailyTallyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daily Tally',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(context, listen: false).fetchTransactions();
    });
  }

  void _showAddTransactionModal(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    String type = 'expense';
    String category = provider.getCategoriesForType('expense')[0];
    final dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: type,
                    decoration: const InputDecoration(
                      labelText: 'Transaction Type',
                    ),
                    items: ['income', 'expense']
                        .map((String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value.capitalize()),
                            ))
                        .toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        type = newValue!;
                        category = provider.getCategoriesForType(type)[0];
                      });
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                    ),
                    items: provider
                        .getCategoriesForType(type)
                        .map((String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ))
                        .toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        category = newValue!;
                      });
                    },
                  ),
                  TextField(
                    controller: dateController,
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        dateController.text =
                            DateFormat('yyyy-MM-dd').format(pickedDate);
                      }
                    },
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                    ),
                  ),
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixText: '\$',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      final newTransaction = AppTransaction(
                        date: DateTime.parse(dateController.text),
                        description: descriptionController.text,
                        amount: double.parse(amountController.text),
                        type: type,
                        category: category,
                      );
                      provider.addTransaction(newTransaction);
                      Navigator.pop(context);
                    },
                    child: const Text('Add Transaction'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditTransactionModal(BuildContext context, AppTransaction transaction) {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    String type = transaction.type;
    String category = transaction.category;
    final dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(transaction.date),
    );
    final descriptionController = TextEditingController(text: transaction.description);
    final amountController = TextEditingController(text: transaction.amount.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: type,
                    decoration: const InputDecoration(
                      labelText: 'Transaction Type',
                    ),
                    items: ['income', 'expense']
                        .map((String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value.capitalize()),
                            ))
                        .toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        type = newValue!;
                        category = provider.getCategoriesForType(type)[0];
                      });
                    },
                  ),
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                    ),
                    items: provider
                        .getCategoriesForType(type)
                        .map((String value) => DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            ))
                        .toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        category = newValue!;
                      });
                    },
                  ),
                  TextField(
                    controller: dateController,
                    decoration: const InputDecoration(
                      labelText: 'Date',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        dateController.text =
                            DateFormat('yyyy-MM-dd').format(pickedDate);
                      }
                    },
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                    ),
                  ),
                  TextField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixText: '\$',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      final updatedTransaction = AppTransaction(
                        id: transaction.id,
                        date: DateTime.parse(dateController.text),
                        description: descriptionController.text,
                        amount: double.parse(amountController.text),
                        type: type,
                        category: category,
                      );
                      provider.updateTransaction(updatedTransaction);
                      Navigator.pop(context);
                    },
                    child: const Text('Update Transaction'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Tally'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () async {
              final provider = Provider.of<TransactionProvider>(context, listen: false);
              DateTime? pickedMonth = await showDatePicker(
                context: context,
                initialDate: provider.selectedMonth,
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
                initialDatePickerMode: DatePickerMode.year,
              );
              if (pickedMonth != null) {
                provider.changeMonth(pickedMonth);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CategoryManagementScreen(),
                ),
              );
            },
            tooltip: 'Manage Categories',
          ),
        ],
      ),
      body: Column(
        children: [
          Consumer<TransactionProvider>(
            builder: (context, provider, child) {
              return FutureBuilder<Map<String, double>>(
                future: provider.getMonthlySummary(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  final summary = snapshot.data ?? {'income': 0.0, 'expense': 0.0, 'balance': 0.0};
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              const Text('Income', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('₹${summary['income']?.toStringAsFixed(2) ?? '0.00'}', 
                                   style: const TextStyle(color: Colors.green)),
                            ],
                          ),
                          Column(
                            children: [
                              const Text('Expense', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('₹${summary['expense']?.toStringAsFixed(2) ?? '0.00'}', 
                                   style: const TextStyle(color: Colors.red)),
                            ],
                          ),
                          Column(
                            children: [
                              const Text('Balance', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('₹${summary['balance']?.toStringAsFixed(2) ?? '0.00'}', 
                                   style: TextStyle(
                                     color: (summary['balance'] ?? 0) >= 0 ? Colors.blue : Colors.red
                                   )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
          Expanded(
            child: Consumer<TransactionProvider>(
              builder: (context, provider, child) {
                return ListView.builder(
                  itemCount: provider.transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = provider.transactions[index];
                    return Dismissible(
                      key: Key(transaction.id.toString()),
                      background: Container(color: Colors.red),
                      onDismissed: (direction) {
                        provider.deleteTransaction(transaction.id!);
                      },
                      child: ListTile(
                        title: Text(transaction.description),
                        subtitle: Text('${transaction.category} | ${DateFormat('yyyy-MM-dd').format(transaction.date)}'),
                        trailing: Text(
                          '₹${transaction.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: transaction.type == 'income' ? Colors.green : Colors.red,
                          ),
                        ),
                        onTap: () => _showEditTransactionModal(context, transaction),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionModal(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
