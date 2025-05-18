import 'package:dartz/dartz.dart';
import 'package:personal_finance/app/core/state/base_state.dart';
import 'package:personal_finance/app/models/transaction_model.dart';
import 'package:personal_finance/app/mothly/domain/usecases/update_transaction_usecase.dart';
import 'package:personal_finance/app/mothly/ui/stores/get_transactions_store.dart';

class UpdateTransactionStore extends BaseController<Unit> {
  final UpdateTransactionUsecase usecase;
  final GetTransactionsStore getTransactionsStore;
  UpdateTransactionStore(this.usecase, this.getTransactionsStore) : super(unit);

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
        getTransactionsStore(transaction.year, transaction.month);
      },
    );
  }
}
