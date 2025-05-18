import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:personal_finance/app/core/failures/failure.dart';
import 'package:personal_finance/app/models/transaction_model.dart';

abstract class TransactionFirestoreDatasource {
  Future<Either<Failure, Unit>> createTransaction(TransactionModel transaction);
  Future<Either<Failure, Unit>> createSingleTransaction(TransactionModel transaction);
  Future<Either<Failure, Unit>> updateTransaction(TransactionModel transaction);
  Future<Either<Failure, Unit>> updateSingleTransaction(TransactionModel transaction);
  Future<Either<Failure, List<TransactionModel>>> getRecurringTransactions();
  Future<Either<Failure, List<TransactionModel>>> getTransactionsByYearMonth(int year, int month);
}

class TransactionFirestoreDatasourceImpl implements TransactionFirestoreDatasource {
  final FirebaseFirestore firestore;

  TransactionFirestoreDatasourceImpl(this.firestore);

  @override
  Future<Either<Failure, Unit>> createTransaction(TransactionModel transaction) async {
    try {
      await firestore.collection('recurring_transactions').doc().set(transaction.toJson());
      return Right(unit);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateTransaction(TransactionModel transaction) async {
    try {
      await firestore
          .collection('recurring_transactions')
          .doc(transaction.id)
          .set(transaction.toJson());
      return Right(unit);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> createSingleTransaction(TransactionModel transaction) async {
    try {
      await firestore
          .collection('years')
          .doc('${transaction.year}')
          .collection('${transaction.year}-${transaction.month}')
          .doc()
          .set(transaction.toJson());
      return Right(unit);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateSingleTransaction(TransactionModel transaction) async {
    try {
      // collection {ano} - collection {mes} - document {ano-mes}
      await firestore
          .collection('years')
          .doc('${transaction.year}')
          .collection('${transaction.year}-${transaction.month}')
          .doc(transaction.id)
          .set(transaction.toJson());
      return Right(unit);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<TransactionModel>>> getRecurringTransactions() async {
    final snapshot = await firestore.collection('recurring_transactions').get();
    return Right(snapshot.docs.map((e) => TransactionModel.fromJson(e.id, e.data())).toList());
  }

  @override
  Future<Either<Failure, List<TransactionModel>>> getTransactionsByYearMonth(
    int year,
    int month,
  ) async {
    final snapshot =
        await firestore.collection('years').doc('$year').collection('$year-$month').get();
    return Right(snapshot.docs.map((e) => TransactionModel.fromJson(e.id, e.data())).toList());
  }
}
