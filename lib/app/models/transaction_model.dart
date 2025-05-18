import 'package:personal_finance/app/models/expense_model.dart';
import 'package:personal_finance/app/models/income_model.dart';

enum TransactionFormType { unica, recorrente, parcelada }

enum TransactionType { income, expense }

abstract class TransactionModel {
  final String id;
  final int year; // Ano do mês
  final int month; // Mês
  final String description;
  final double expected;
  double realized;
  final int dueDay;
  final TransactionFormType formType;
  final TransactionType type;
  final DateTime? deletedAt;
  final DateTime? realizedDate;
  final DateTime updateAt;

  TransactionModel({
    required this.id,
    required this.year,
    required this.month,
    required this.description,
    required this.expected,
    required this.realized,
    required this.dueDay,
    required this.formType,
    required this.updateAt,
    required this.type,
    this.realizedDate,
    this.deletedAt,
  });

  Map<String, dynamic> toJson();

  factory TransactionModel.fromJson(String id, Map<String, dynamic> json) {
    return json['type'] == 'income'
        ? IncomeModel.fromJson(id, json)
        : ExpenseModel.fromJson(id, json);
  }
}
