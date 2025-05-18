import 'package:dartz/dartz.dart';
import 'package:personal_finance/app/core/state/base_state.dart';
import 'package:personal_finance/app/models/transaction_model.dart';
import 'package:personal_finance/app/mothly/domain/usecases/create_transaction_usecase.dart';
import 'package:personal_finance/app/mothly/ui/stores/get_transactions_store.dart';

class CreateNewTransactionStore extends BaseController<Unit> {
  final CreateTransactionUsecase usecase;
  final GetTransactionsStore getTransactionsStore;
  CreateNewTransactionStore(this.usecase, this.getTransactionsStore) : super(unit);

  Future<void> call(TransactionModel transaction) async {
    setLoading();
    final result = await usecase(transaction);
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
