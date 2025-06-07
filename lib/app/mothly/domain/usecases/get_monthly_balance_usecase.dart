import 'package:dartz/dartz.dart';
import 'package:personal_finance/app/core/failures/failure.dart';
import 'package:personal_finance/app/models/monthly_balance_model.dart';
import 'package:personal_finance/app/mothly/domain/repositories/monthly_balance_repository.dart';
import 'package:personal_finance/app/mothly/domain/usecases/calculate_monthly_balance_usecase.dart';

class GetMonthlyBalanceUsecase {
  final MonthlyBalanceRepository repository;
  final CalculateMonthlyBalanceUsecase calculateMonthlyBalanceUsecase;

  GetMonthlyBalanceUsecase(this.repository, this.calculateMonthlyBalanceUsecase);

  Future<Either<Failure, MonthlyBalanceModel>> call(int year, int month) async {
    try {
      // Tentar buscar o saldo mensal
      final result = await repository.getMonthlyBalance(year, month);

      // Se não existir ou ocorrer erro, calcular o saldo
      if (result.isLeft()) {
        return calculateMonthlyBalanceUsecase(year, month);
      }

      return result;
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
