import 'package:personal_finance/app/core/state/base_state.dart';
import 'package:personal_finance/app/models/transaction_model.dart';
import 'package:personal_finance/app/mothly/domain/usecases/get_transactions_usecase.dart';
import 'package:personal_finance/app/mothly/ui/stores/monthly_balance_store.dart';

class GetTransactionsStore extends BaseController<List<TransactionModel>> {
  final GetTransactionsUsecase usecase;
  final MonthlyBalanceStore monthlyBalanceStore;

  GetTransactionsStore(this.usecase, this.monthlyBalanceStore) : super([]);

  List<TransactionModel> get expenses =>
      success.value.where((e) => e.type == TransactionType.expense).toList();
  List<TransactionModel> get incomes =>
      success.value.where((e) => e.type == TransactionType.income).toList();
  List<TransactionModel> get allTransactions => success.value;

  double get totalExpenses =>
      expenses.fold<double>(0.0, (previous, element) => previous + element.realized);
  double get totalIncomes =>
      incomes.fold<double>(0.0, (previous, element) => previous + element.realized);

  double get totalExpensesExpected =>
      expenses.fold<double>(0.0, (previous, element) => previous + element.expected);
  double get totalIncomesExpected =>
      incomes.fold<double>(0.0, (previous, element) => previous + element.expected);

  double get balance => totalIncomes - totalExpenses;
  double get balanceExpected => totalIncomesExpected - totalExpensesExpected;

  Future<void> call(int year, int month) async {
    setLoading();

    final result = await usecase(year, month);
    result.fold(
      (error) {
        setError(error);
      },
      (data) {
        update(data);
        // Recalcular o saldo mensal após obter as transações
        monthlyBalanceStore.recalculateAfterTransactionChange(year, month);
      },
    );
  }
}
