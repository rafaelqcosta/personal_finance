import 'package:dartz/dartz.dart';
import 'package:personal_finance/app/core/failures/failure.dart';
import 'package:personal_finance/app/models/transaction_model.dart';
import 'package:personal_finance/app/mothly/domain/repositories/transaction_repository.dart';
import 'package:personal_finance/app/mothly/domain/usecases/update_future_monthly_balances_usecase.dart';

class CreateTransactionUsecase {
  final TransactionRepository repository;
  final UpdateFutureMonthlyBalancesUsecase updateFutureMonthlyBalancesUsecase;

  CreateTransactionUsecase(this.repository, this.updateFutureMonthlyBalancesUsecase);

  Future<Either<Failure, Unit>> call(TransactionModel transaction) async {
    try {
      final result = await repository.add(transaction);

      if (result.isRight()) {
        // Após adicionar a transação, atualizar os saldos mensais a partir do mês da transação
        await updateFutureMonthlyBalancesUsecase(transaction.year, transaction.month);
      }

      return result;
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
