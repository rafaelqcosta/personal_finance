import 'package:dartz/dartz.dart';
import 'package:personal_finance/app/core/failures/failure.dart';
import 'package:personal_finance/app/models/expense_model.dart';
import 'package:personal_finance/app/models/transaction_model.dart';
import 'package:personal_finance/app/mothly/domain/repositories/transaction_repository.dart';

class CreateTransactionUsecase {
  final TransactionRepository repository;

  CreateTransactionUsecase(this.repository);

  Future<Either<Failure, Unit>> call(TransactionModel transaction) {
    if (transaction is ExpenseModel) {
      if (transaction.formType == TransactionFormType.parcelada &&
          transaction.totalInstallments == null) {
        throw Failure('O total de parcelas deve ser informado');
      }
    }

    if (transaction.formType == TransactionFormType.unica) {
      return repository.addSingle(transaction);
    } else {
      return repository.add(transaction);
    }
  }
}
