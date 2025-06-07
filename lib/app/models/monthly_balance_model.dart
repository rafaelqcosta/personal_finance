import 'package:personal_finance/app/models/transaction_model.dart';

class MonthlyBalanceModel {
  final int year;
  final int month;
  final double previousExpectedBalance;
  final double previousRealizedBalance;
  final double expectedIncome;
  final double realizedIncome;
  final double expectedExpense;
  final double realizedExpense;
  final double finalExpectedBalance;
  final double finalRealizedBalance;
  final DateTime updatedAt;

  MonthlyBalanceModel({
    required this.year,
    required this.month,
    required this.previousExpectedBalance,
    required this.previousRealizedBalance,
    required this.expectedIncome,
    required this.realizedIncome,
    required this.expectedExpense,
    required this.realizedExpense,
    required this.finalExpectedBalance,
    required this.finalRealizedBalance,
    required this.updatedAt,
  });

  factory MonthlyBalanceModel.empty(int year, int month) {
    return MonthlyBalanceModel(
      year: year,
      month: month,
      previousExpectedBalance: 0.0,
      previousRealizedBalance: 0.0,
      expectedIncome: 0.0,
      realizedIncome: 0.0,
      expectedExpense: 0.0,
      realizedExpense: 0.0,
      finalExpectedBalance: 0.0,
      finalRealizedBalance: 0.0,
      updatedAt: DateTime.now(),
    );
  }

  factory MonthlyBalanceModel.fromTransactions({
    required int year,
    required int month,
    required List<TransactionModel> transactions,
    required MonthlyBalanceModel? previousMonthBalance,
  }) {
    // Calcular totais de receitas e despesas
    double expectedIncome = 0.0;
    double realizedIncome = 0.0;
    double expectedExpense = 0.0;
    double realizedExpense = 0.0;
    
    for (final transaction in transactions) {
      if (transaction.type == TransactionType.income) {
        expectedIncome += transaction.expected;
        realizedIncome += transaction.realized;
      } else {
        expectedExpense += transaction.expected;
        realizedExpense += transaction.realized;
      }
    }
    
    // Obter saldo do mês anterior
    final previousExpectedBalance = previousMonthBalance?.finalExpectedBalance ?? 0.0;
    final previousRealizedBalance = previousMonthBalance?.finalRealizedBalance ?? 0.0;
    
    // Calcular saldos finais
    final finalExpectedBalance = previousExpectedBalance + expectedIncome - expectedExpense;
    final finalRealizedBalance = previousRealizedBalance + realizedIncome - realizedExpense;
    
    return MonthlyBalanceModel(
      year: year,
      month: month,
      previousExpectedBalance: previousExpectedBalance,
      previousRealizedBalance: previousRealizedBalance,
      expectedIncome: expectedIncome,
      realizedIncome: realizedIncome,
      expectedExpense: expectedExpense,
      realizedExpense: realizedExpense,
      finalExpectedBalance: finalExpectedBalance,
      finalRealizedBalance: finalRealizedBalance,
      updatedAt: DateTime.now(),
    );
  }

  MonthlyBalanceModel copyWith({
    int? year,
    int? month,
    double? previousExpectedBalance,
    double? previousRealizedBalance,
    double? expectedIncome,
    double? realizedIncome,
    double? expectedExpense,
    double? realizedExpense,
    double? finalExpectedBalance,
    double? finalRealizedBalance,
    DateTime? updatedAt,
  }) {
    return MonthlyBalanceModel(
      year: year ?? this.year,
      month: month ?? this.month,
      previousExpectedBalance: previousExpectedBalance ?? this.previousExpectedBalance,
      previousRealizedBalance: previousRealizedBalance ?? this.previousRealizedBalance,
      expectedIncome: expectedIncome ?? this.expectedIncome,
      realizedIncome: realizedIncome ?? this.realizedIncome,
      expectedExpense: expectedExpense ?? this.expectedExpense,
      realizedExpense: realizedExpense ?? this.realizedExpense,
      finalExpectedBalance: finalExpectedBalance ?? this.finalExpectedBalance,
      finalRealizedBalance: finalRealizedBalance ?? this.finalRealizedBalance,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
