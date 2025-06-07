import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:personal_finance/app/app_routes.dart';
import 'package:personal_finance/app/mothly/domain/repositories/transaction_repository.dart';
import 'package:personal_finance/app/mothly/domain/usecases/create_transaction_usecase.dart';
import 'package:personal_finance/app/mothly/domain/usecases/get_transactions_usecase.dart';
import 'package:personal_finance/app/mothly/domain/usecases/update_transaction_usecase.dart';
import 'package:personal_finance/app/mothly/external/datasources/transaction_firestore_datasource.dart';
import 'package:personal_finance/app/mothly/infra/repositories/transaction_repository_impl.dart';
import 'package:personal_finance/app/mothly/ui/pages/monthly_page.dart';
import 'package:personal_finance/app/mothly/ui/stores/create_new_transaction_store.dart';
import 'package:personal_finance/app/mothly/ui/stores/get_transactions_store.dart';
import 'package:personal_finance/app/mothly/ui/stores/monthly_balance_store.dart';
import 'package:personal_finance/app/mothly/ui/stores/update_transaction_store.dart';

class AppModule extends Module {
  @override
  void binds(i) {
    i.addInstance(FirebaseFirestore.instance);
    i.add<TransactionFirestoreDatasource>(TransactionFirestoreDatasourceImpl.new);
    i.add<TransactionRepository>(TransactionRepositoryImpl.new);
    // CreateTransaction
    i.add(CreateTransactionUsecase.new);
    i.addLazySingleton(CreateNewTransactionStore.new);
    // GetTransactions
    i.add(GetTransactionsUsecase.new);
    i.addLazySingleton(GetTransactionsStore.new);
    // UpdateTransaction
    i.add(UpdateTransactionUsecase.new);
    i.addLazySingleton(UpdateTransactionStore.new);
    // MonthlyBalance
    i.addLazySingleton(MonthlyBalanceStore.new);
  }

  @override
  void routes(r) {
    r.child(AppRoutes.root.path, child: (context) => MonthlyPage());
  }
}
