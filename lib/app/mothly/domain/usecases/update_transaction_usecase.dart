import 'package:dartz/dartz.dart';
import 'package:personal_finance/app/core/failures/failure.dart';
import 'package:personal_finance/app/models/expense_model.dart';
import 'package:personal_finance/app/models/transaction_model.dart';
import 'package:personal_finance/app/mothly/domain/repositories/transaction_repository.dart';

class UpdateTransactionUsecase {
  final TransactionRepository repository;

  UpdateTransactionUsecase(this.repository);

  Future<Either<Failure, Unit>> call({
    required TransactionModel transaction,
    required bool onlyOneTransaction,
  }) async {
    if (transaction is ExpenseModel) {
      if (transaction.formType == TransactionFormType.parcelada &&
          transaction.totalInstallments == null) {
        return Left(Failure('O total de parcelas deve ser informado'));
      }
    }

    if (transaction.formType == TransactionFormType.unica) {
      return repository.updateSingle(transaction);
    } else {
      if (onlyOneTransaction) {
        return repository.updateSingle(transaction);
      }
      return repository.update(transaction);
    }
  }
}
