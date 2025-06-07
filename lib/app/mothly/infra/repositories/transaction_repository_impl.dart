import 'package:dartz/dartz.dart';
import 'package:personal_finance/app/core/failures/failure.dart';
import 'package:personal_finance/app/models/transaction_model.dart';
import 'package:personal_finance/app/mothly/domain/repositories/transaction_repository.dart';
import 'package:personal_finance/app/mothly/external/datasources/transaction_firestore_datasource.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionFirestoreDatasource datasource;

  TransactionRepositoryImpl(this.datasource);

  @override
  Future<Either<Failure, Unit>> add(TransactionModel transaction) =>
      datasource.createTransaction(transaction);

  @override
  Future<Either<Failure, Unit>> addSingle(TransactionModel transaction) =>
      datasource.createSingleTransaction(transaction);

  @override
  Future<Either<Failure, Unit>> update(TransactionModel transaction) =>
      datasource.updateTransaction(transaction);

  @override
  Future<Either<Failure, Unit>> updateSingle(TransactionModel transaction) =>
      datasource.updateSingleTransaction(transaction);

  @override
  Future<Either<Failure, List<TransactionModel>>> getRecurringTransactions() =>
      datasource.getRecurringTransactions();

  @override
  Future<Either<Failure, List<TransactionModel>>> getTransactionsByYearMonth(int year, int month) =>
      datasource.getTransactionsByYearMonth(year, month);
}
