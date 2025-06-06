import 'package:dartz/dartz.dart';
import 'package:personal_finance/app/core/state/base_state.dart';
import 'package:personal_finance/app/models/transaction_model.dart';
import 'package:personal_finance/app/mothly/domain/usecases/update_transaction_usecase.dart';
import 'package:personal_finance/app/mothly/ui/stores/get_transactions_store.dart';
import 'package:personal_finance/app/mothly/ui/stores/monthly_balance_store.dart';

class UpdateTransactionStore extends BaseController<Unit> {
  final UpdateTransactionUsecase usecase;
  final GetTransactionsStore getTransactionsStore;
  final MonthlyBalanceStore monthlyBalanceStore;

  UpdateTransactionStore(this.usecase, this.getTransactionsStore, this.monthlyBalanceStore)
    : super(unit);

  Future<void> call({
    required TransactionModel transaction,
    required bool onlyOneTransaction,
  }) async {
    setLoading();
    final result = await usecase(transaction: transaction, onlyOneTransaction: onlyOneTransaction);
    result.fold(
      (error) {
        setError(error);
      },
      (data) {
        update(data);
        // Atualizar as transações do mês
        getTransactionsStore(transaction.year, transaction.month);
        // Recalcular o saldo mensal e propagar para os meses seguintes
        monthlyBalanceStore.recalculateAfterTransactionChange(transaction.year, transaction.month);
      },
    );
  }
}
