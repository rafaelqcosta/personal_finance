import 'package:dartz/dartz.dart';
import 'package:personal_finance/app/core/failures/failure.dart';
import 'package:personal_finance/app/models/monthly_balance_model.dart';
import 'package:personal_finance/app/models/transaction_model.dart';
import 'package:personal_finance/app/mothly/domain/repositories/monthly_balance_repository.dart';
import 'package:personal_finance/app/mothly/domain/repositories/transaction_repository.dart';

class CalculateMonthlyBalanceUsecase {
  final TransactionRepository transactionRepository;
  final MonthlyBalanceRepository monthlyBalanceRepository;

  CalculateMonthlyBalanceUsecase(this.transactionRepository, this.monthlyBalanceRepository);

  Future<Either<Failure, MonthlyBalanceModel>> call(int year, int month) async {
    try {
      // Buscar transações do mês atual
      final transactionsResult = await transactionRepository.getTransactionsByYearMonth(
        year,
        month,
      );

      if (transactionsResult.isLeft()) {
        return Left(transactionsResult.fold((l) => l, (r) => Failure('Erro desconhecido')));
      }

      final transactions = transactionsResult.getOrElse(() => []);

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

      // Buscar saldo do mês anterior
      final previousMonth = month == 1 ? 12 : month - 1;
      final previousYear = month == 1 ? year - 1 : year;

      final previousBalanceResult = await monthlyBalanceRepository.getMonthlyBalance(
        previousYear,
        previousMonth,
      );

      final previousBalance = previousBalanceResult.fold(
        (l) => MonthlyBalanceModel(
          year: previousYear,
          month: previousMonth,
          previousExpectedBalance: 0.0,
          previousRealizedBalance: 0.0,
          expectedIncome: 0.0,
          realizedIncome: 0.0,
          expectedExpense: 0.0,
          realizedExpense: 0.0,
          finalExpectedBalance: 0.0,
          finalRealizedBalance: 0.0,
          updatedAt: DateTime.now(),
        ),
        (r) => r,
      );

      // Calcular saldos finais
      final finalExpectedBalance =
          previousBalance.finalExpectedBalance + expectedIncome - expectedExpense;
      final finalRealizedBalance =
          previousBalance.finalRealizedBalance + realizedIncome - realizedExpense;

      // Criar modelo de saldo mensal
      final monthlyBalance = MonthlyBalanceModel(
        year: year,
        month: month,
        previousExpectedBalance: previousBalance.finalExpectedBalance,
        previousRealizedBalance: previousBalance.finalRealizedBalance,
        expectedIncome: expectedIncome,
        realizedIncome: realizedIncome,
        expectedExpense: expectedExpense,
        realizedExpense: realizedExpense,
        finalExpectedBalance: finalExpectedBalance,
        finalRealizedBalance: finalRealizedBalance,
        updatedAt: DateTime.now(),
      );

      // Salvar saldo mensal
      await monthlyBalanceRepository.saveMonthlyBalance(monthlyBalance);

      return Right(monthlyBalance);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
