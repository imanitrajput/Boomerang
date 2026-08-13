import 'package:uuid/uuid.dart';

enum TransactionType { borrow, lend }

class Payment {
  final String id;
  final double amount;
  final DateTime date;
  final String note;

  Payment({
    String? id,
    required this.amount,
    required this.date,
    this.note = '',
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'date': date.toIso8601String(),
        'note': note,
      };

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        id: json['id'],
        amount: (json['amount'] as num).toDouble(),
        date: DateTime.parse(json['date']),
        note: json['note'] ?? '',
      );
}

class Debt {
  final String id;
  final TransactionType type;
  final String personName;
  final double amount;
  final String currency;
  final DateTime date;
  final String description;
  final List<Payment> payments;

  Debt({
    String? id,
    required this.type,
    required this.personName,
    required this.amount,
    required this.currency,
    required this.date,
    this.description = '',
    List<Payment>? payments,
  })  : id = id ?? const Uuid().v4(),
        payments = payments ?? [];

  double get totalPaid => payments.fold(0.0, (sum, p) => sum + p.amount);
  double get remainingAmount => amount - totalPaid;
  bool get isPaidOff => remainingAmount <= 0;

  String get currencySymbol {
    switch (currency.toUpperCase()) {
      case 'AUD': return 'A\$';
      case 'INR': return '₹';
      case 'EUR': return '€';
      case 'GBP': return '£';
      case 'JPY': return '¥';
      case 'CAD': return 'C\$';
      case 'USD':
      default: return '\$';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'personName': personName,
        'amount': amount,
        'currency': currency,
        'date': date.toIso8601String(),
        'description': description,
        'payments': payments.map((p) => p.toJson()).toList(),
      };

  factory Debt.fromJson(Map<String, dynamic> json) {
    var list = json['payments'] as List? ?? [];
    List<Payment> paymentsList = list.map((i) => Payment.fromJson(i)).toList();

    return Debt(
      id: json['id'],
      type: TransactionType.values.firstWhere((e) => e.name == json['type'],
          orElse: () => TransactionType.borrow),
      personName: json['personName'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] ?? 'USD',
      date: DateTime.parse(json['date']),
      description: json['description'] ?? '',
      payments: paymentsList,
    );
  }
}
