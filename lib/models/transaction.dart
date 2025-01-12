class AppTransaction {
  int? id;
  final DateTime date;
  final String description;
  final double amount;
  final String type;
  final String category;

  AppTransaction({
    this.id,
    required this.date,
    required this.description,
    required this.amount,
    required this.type,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'description': description,
      'amount': amount,
      'type': type,
      'category': category,
    };
  }

  factory AppTransaction.fromMap(Map<String, dynamic> map) {
    return AppTransaction(
      id: map['id'],
      date: DateTime.parse(map['date']),
      description: map['description'],
      amount: map['amount'],
      type: map['type'],
      category: map['category'],
    );
  }
}
