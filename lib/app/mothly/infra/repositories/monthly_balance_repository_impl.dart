import 'package:dartz/dartz.dart';
import 'package:personal_finance/app/core/failures/failure.dart';
import 'package:personal_finance/app/models/monthly_balance_model.dart';
import 'package:personal_finance/app/mothly/domain/repositories/monthly_balance_repository.dart';
import 'package:personal_finance/app/mothly/external/datasources/monthly_balance_datasource_impl.dart';

class MonthlyBalanceRepositoryImpl implements MonthlyBalanceRepository {
  final MonthlyBalanceFirestoreDatasource datasource;

  MonthlyBalanceRepositoryImpl(this.datasource);

  @override
  Future<Either<Failure, MonthlyBalanceModel>> getMonthlyBalance(int year, int month) =>
      datasource.getMonthlyBalance(year, month);

  @override
  Future<Either<Failure, Unit>> saveMonthlyBalance(MonthlyBalanceModel balance) =>
      datasource.saveMonthlyBalance(balance);

  @override
  Future<Either<Failure, List<MonthlyBalanceModel>>> getAllMonthlyBalances() =>
      datasource.getAllMonthlyBalances();
}
