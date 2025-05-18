import 'package:dartz/dartz.dart';
import 'package:personal_finance/app/core/failures/failure.dart';
import 'package:personal_finance/app/models/expense_model.dart';
import 'package:personal_finance/app/models/transaction_model.dart';
import 'package:personal_finance/app/mothly/domain/repositories/transaction_repository.dart';

class GetTransactionsUsecase {
  final TransactionRepository repository;

  GetTransactionsUsecase(this.repository);

  Future<Either<Failure, List<TransactionModel>>> call(int year, int month) async {
    try {
      final recurringResult = await getRecurring(year, month);
      final monthResult = await getByYearMonth(year, month);

      // Se ocorrer erro em uma das chamadas, retorne o erro
      if (monthResult.isLeft()) return monthResult;
      if (recurringResult.isLeft()) return recurringResult;

      final monthTransactions = monthResult.getOrElse(() => []);
      final recurringTransactions = recurringResult.getOrElse(() => []);

      final existingIds = monthTransactions.map((t) => t.id).toSet();

      final mergedList = [
        ...monthTransactions,
        ...recurringTransactions.where((t) => !existingIds.contains(t.id)),
      ];

      return Right(mergedList);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, List<TransactionModel>>> getRecurring(int year, int month) async {
    try {
      final result = await repository.getRecurringTransactions();
      if (result.isLeft()) return result;

      final recurringTransactions = result.getOrElse(() => []);

      final filtered =
          recurringTransactions.where((t) {
            // ❗️Filtro para TODAS as transações: só a partir do mês/ano de updateAt
            final isCreatedBeforeOrSameMonth = DateTime(
              t.updateAt.year,
              t.updateAt.month,
            ).isBefore(DateTime(year, month + 1));
            if (!isCreatedBeforeOrSameMonth) return false;

            // 👇 Regra adicional apenas para parceladas
            if (t is ExpenseModel) {
              return isInstallmentActive(t, year, month);
            }

            return true;
          }).toList();

      return Right(filtered);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  bool isInstallmentActive(ExpenseModel t, int year, int month) {
    if (t.formType != TransactionFormType.parcelada || t.totalInstallments == null) return true;

    final monthsSinceCreated = (year - t.updateAt.year) * 12 + (month - t.updateAt.month);

    return monthsSinceCreated >= 0 && monthsSinceCreated < t.totalInstallments!;
  }

  Future<Either<Failure, List<TransactionModel>>> getByYearMonth(int year, int month) async {
    try {
      final result = await repository.getTransactionsByYearMonth(year, month);
      return result;
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
