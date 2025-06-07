import 'package:dartz/dartz.dart';
import 'package:personal_finance/app/core/failures/failure.dart';
import 'package:personal_finance/app/mothly/domain/repositories/monthly_balance_repository.dart';
import 'package:personal_finance/app/mothly/domain/usecases/calculate_monthly_balance_usecase.dart';

class UpdateFutureMonthlyBalancesUsecase {
  final MonthlyBalanceRepository monthlyBalanceRepository;
  final CalculateMonthlyBalanceUsecase calculateMonthlyBalanceUsecase;

  UpdateFutureMonthlyBalancesUsecase(
    this.monthlyBalanceRepository,
    this.calculateMonthlyBalanceUsecase,
  );

  Future<Either<Failure, Unit>> call(int startYear, int startMonth) async {
    try {
      // Obter data atual
      final now = DateTime.now();

      // Definir mês e ano inicial
      var currentYear = startYear;
      var currentMonth = startMonth;

      // Recalcular todos os meses até o mês atual
      while (currentYear < now.year || (currentYear == now.year && currentMonth <= now.month)) {
        // Calcular saldo do mês atual
        final result = await calculateMonthlyBalanceUsecase(currentYear, currentMonth);

        if (result.isLeft()) {
          return Left(result.fold((l) => l, (r) => Failure('Erro desconhecido')));
        }

        // Avançar para o próximo mês
        if (currentMonth == 12) {
          currentYear++;
          currentMonth = 1;
        } else {
          currentMonth++;
        }
      }

      return const Right(unit);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }
}
