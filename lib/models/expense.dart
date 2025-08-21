class Expense {
  int? id;
  String title;
  double amount;
  String currency;
  String category;
  DateTime date;
  bool synced;
  String? action; // 'create', 'update', 'delete'

  Expense({
    this.id,
    required this.title,
    required this.amount,
    required this.currency,
    required this.category,
    required this.date,
    this.synced = false,
    this.action,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'currency': currency,
      'category': category,
      'date': date.toIso8601String(),
      'synced': synced ? 1 : 0,
      'action': action,
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      title: json['title'],
      amount: json['amount'].toDouble(),
      currency: json['currency'],
      category: json['category'],
      date: DateTime.parse(json['date']),
      synced: json['synced'] == 1,
      action: json['action'],
    );
  }
}
