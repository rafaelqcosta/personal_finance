import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:personal_finance/app/core/failures/failure.dart';
import 'package:personal_finance/app/models/monthly_balance_model.dart';

abstract class MonthlyBalanceFirestoreDatasource {
  Future<Either<Failure, MonthlyBalanceModel>> getMonthlyBalance(int year, int month);
  Future<Either<Failure, Unit>> saveMonthlyBalance(MonthlyBalanceModel balance);
  Future<Either<Failure, List<MonthlyBalanceModel>>> getAllMonthlyBalances();
}

class MonthlyBalanceFirestoreDatasourceImpl implements MonthlyBalanceFirestoreDatasource {
  final FirebaseFirestore firestore;

  MonthlyBalanceFirestoreDatasourceImpl(this.firestore);

  @override
  Future<Either<Failure, MonthlyBalanceModel>> getMonthlyBalance(int year, int month) async {
    try {
      final result =
          await firestore
              .collection('monthly_balances')
              .where('year', isEqualTo: year)
              .where('month', isEqualTo: month)
              .get();

      if (result.docs.isEmpty) {
        // Retorna um balance zerado se não existir
        return Right(
          MonthlyBalanceModel(
            id: '',
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
          ),
        );
      }

      final doc = result.docs.first;
      return Right(MonthlyBalanceModel.fromJson(doc.id, doc.data()));
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveMonthlyBalance(MonthlyBalanceModel balance) async {
    try {
      final query =
          await firestore
              .collection('monthly_balances')
              .where('year', isEqualTo: balance.year)
              .where('month', isEqualTo: balance.month)
              .get();

      if (query.docs.isEmpty) {
        // Criar novo documento
        await firestore.collection('monthly_balances').add(balance.toJson());
      } else {
        // Atualizar documento existente
        await firestore
            .collection('monthly_balances')
            .doc(query.docs.first.id)
            .update(balance.toJson());
      }

      return const Right(unit);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MonthlyBalanceModel>>> getAllMonthlyBalances() async {
    try {
      final result = await firestore.collection('monthly_balances').get();

      final balances =
          result.docs.map((doc) => MonthlyBalanceModel.fromJson(doc.id, doc.data())).toList();

      return Right(balances);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
