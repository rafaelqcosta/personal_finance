import 'package:personal_finance/app/models/transaction_model.dart';

class ExpenseModel extends TransactionModel {
  final String category;
  final int? totalInstallments;
  final String? creditCardId;

  ExpenseModel({
    required super.id,
    required super.year,
    required super.month,
    required super.description,
    required super.expected,
    required super.dueDay,
    required super.formType,
    required this.category,
    required super.realized,
    required super.updateAt,
    required super.type,
    super.realizedDate,
    this.totalInstallments,
    this.creditCardId,
    super.deletedAt,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'year': year,
      'month': month,
      'expected': expected,
      'realized': realized,
      'dueDay': dueDay,
      'formType': formType.name,
      'type': type.name,
      'updateAt': updateAt.toIso8601String(),
      'realizedDate': realizedDate?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'category': category,
      'totalInstallments': totalInstallments,
      'creditCardId': creditCardId,
    };
  }

  factory ExpenseModel.fromJson(String id, Map<String, dynamic> json) {
    return ExpenseModel(
      id: id,
      year: json['year'],
      month: json['month'],
      description: json['description'],
      expected: (json['expected'] as num).toDouble(),
      realized: (json['realized'] as num?)?.toDouble() ?? 0.0,
      dueDay: json['dueDay'],
      formType: TransactionFormType.values.byName(json['formType']),
      type: TransactionType.values.byName(json['type']),
      updateAt: DateTime.parse(json['updateAt']),
      realizedDate: json['realizedDate'] != null ? DateTime.parse(json['realizedDate']) : null,
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
      category: json['category'],
      totalInstallments: json['totalInstallments'],
      creditCardId: json['creditCardId'],
    );
  }

  ExpenseModel copyWith({
    String? id,
    int? year,
    int? month,
    String? description,
    double? expected,
    double? realized,
    int? dueDay,
    TransactionFormType? formType,
    TransactionType? type,
    DateTime? updateAt,
    DateTime? realizedDate,
    DateTime? deletedAt,
    String? category,
    int? totalInstallments,
    int? currentInstallment,
    String? creditCardId,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      year: year ?? this.year,
      month: month ?? this.month,
      description: description ?? this.description,
      expected: expected ?? this.expected,
      realized: realized ?? this.realized,
      dueDay: dueDay ?? this.dueDay,
      formType: formType ?? this.formType,
      type: type ?? this.type,
      updateAt: updateAt ?? this.updateAt,
      realizedDate: realizedDate ?? this.realizedDate,
      deletedAt: deletedAt ?? this.deletedAt,
      category: category ?? this.category,
      totalInstallments: totalInstallments ?? this.totalInstallments,
      creditCardId: creditCardId ?? this.creditCardId,
    );
  }
}
