import 'package:dartz/dartz.dart';
import 'package:personal_finance/app/core/failures/failure.dart';
import 'package:personal_finance/app/models/transaction_model.dart';

abstract class TransactionRepository {
  Future<Either<Failure, Unit>> add(TransactionModel transaction);
  Future<Either<Failure, Unit>> addSingle(TransactionModel transaction);
  Future<Either<Failure, Unit>> update(TransactionModel transaction);
  Future<Either<Failure, Unit>> updateSingle(TransactionModel transaction);
  Future<Either<Failure, List<TransactionModel>>> getTransactionsByYearMonth(int year, int month);
  Future<Either<Failure, List<TransactionModel>>> getRecurringTransactions();
}
