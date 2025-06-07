import 'package:flutter/material.dart';
import 'package:personal_finance/app/models/transaction_model.dart';
import 'package:personal_finance/app/mothly/domain/usecases/get_transactions_usecase.dart';

class MonthlyBalanceStore {
  // Armazena os saldos mensais calculados
  final _balancesMap = <String, ValueNotifier<MonthlyBalanceModel>>{};
  
  // Usecase para obter transações
  final GetTransactionsUsecase getTransactionsUsecase;
  
  MonthlyBalanceStore(this.getTransactionsUsecase);
  
  // Método para obter o ValueNotifier de um mês específico
  ValueNotifier<MonthlyBalanceModel> getMonthlyBalance(int year, int month) {
    final key = '$year-$month';
    
    // Cria um novo ValueNotifier se não existir
    if (!_balancesMap.containsKey(key)) {
      _balancesMap[key] = ValueNotifier(MonthlyBalanceModel.empty(year, month));
      // Calcula o saldo inicial
      _calculateMonthlyBalance(year, month);
    }
    
    return _balancesMap[key]!;
  }
  
  // Método para calcular o saldo de um mês específico
  Future<void> _calculateMonthlyBalance(int year, int month) async {
    final key = '$year-$month';
    
    // Buscar transações do mês atual
    final transactionsResult = await getTransactionsUsecase(year, month);
    
    transactionsResult.fold(
      (error) {
        // Em caso de erro, mantém o saldo vazio
        _balancesMap[key]?.value = MonthlyBalanceModel.empty(year, month);
      },
      (transactions) {
        // Buscar saldo do mês anterior
        final previousMonth = month == 1 ? 12 : month - 1;
        final previousYear = month == 1 ? year - 1 : year;
        final previousKey = '$previousYear-$previousMonth';
        
        // Obter o saldo do mês anterior, se existir
        final previousMonthBalance = _balancesMap.containsKey(previousKey) 
            ? _balancesMap[previousKey]!.value 
            : null;
        
        // Calcular o saldo do mês atual
        final monthlyBalance = MonthlyBalanceModel.fromTransactions(
          year: year,
          month: month,
          transactions: transactions,
          previousMonthBalance: previousMonthBalance,
        );
        
        // Atualizar o ValueNotifier
        _balancesMap[key]?.value = monthlyBalance;
        
        // Propagar a atualização para os meses seguintes
        _updateFutureMonths(year, month);
      },
    );
  }
  
  // Método para atualizar os saldos dos meses seguintes
  Future<void> _updateFutureMonths(int startYear, int startMonth) async {
    // Obter data atual
    final now = DateTime.now();
    
    // Definir mês e ano inicial
    var currentYear = startYear;
    var currentMonth = startMonth + 1;
    
    // Ajustar para o próximo ano se necessário
    if (currentMonth > 12) {
      currentYear++;
      currentMonth = 1;
    }
    
    // Recalcular todos os meses até o mês atual
    while (currentYear < now.year || (currentYear == now.year && currentMonth <= now.month)) {
      await _calculateMonthlyBalance(currentYear, currentMonth);
      
      // Avançar para o próximo mês
      currentMonth++;
      if (currentMonth > 12) {
        currentYear++;
        currentMonth = 1;
      }
    }
  }
  
  // Método para recalcular o saldo após adicionar ou atualizar uma transação
  Future<void> recalculateAfterTransactionChange(int year, int month) async {
    await _calculateMonthlyBalance(year, month);
  }
}

// Modelo para armazenar os saldos mensais
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
}
