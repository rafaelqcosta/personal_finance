import 'package:dartz/dartz.dart';
import 'package:personal_finance/app/core/failures/failure.dart';
import 'package:personal_finance/app/models/monthly_balance_model.dart';

abstract class MonthlyBalanceRepository {
  Future<Either<Failure, MonthlyBalanceModel>> getMonthlyBalance(int year, int month);
  Future<Either<Failure, Unit>> saveMonthlyBalance(MonthlyBalanceModel balance);
  Future<Either<Failure, List<MonthlyBalanceModel>>> getAllMonthlyBalances();
}
