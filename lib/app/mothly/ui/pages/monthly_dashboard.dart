import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:personal_finance/app/core/design_system/ds_button.dart';
import 'package:personal_finance/app/core/state/base_state.dart';
import 'package:personal_finance/app/core/utils/utils.dart';
import 'package:personal_finance/app/models/transaction_model.dart';
import 'package:personal_finance/app/mothly/ui/pages/components/edit_transaction_bottom_sheet.dart';
import 'package:personal_finance/app/mothly/ui/pages/components/transactions_component.dart';
import 'package:personal_finance/app/mothly/ui/stores/get_transactions_store.dart';
import 'package:personal_finance/app/mothly/ui/stores/monthly_balance_store.dart';

class MonthlyDashboard extends StatefulWidget {
  final int month;
  final int year;
  const MonthlyDashboard({super.key, required this.month, required this.year});

  @override
  State<MonthlyDashboard> createState() => _MonthlyDashboardState();
}

class _MonthlyDashboardState extends State<MonthlyDashboard> {
  final getTransactionsStore = Modular.get<GetTransactionsStore>();
  late final MonthlyBalanceStore monthlyBalanceStore;
  late final ValueNotifier<MonthlyBalanceModel> monthlyBalanceNotifier;

  @override
  void initState() {
    super.initState();
    monthlyBalanceStore = Modular.get<MonthlyBalanceStore>();
    monthlyBalanceNotifier = monthlyBalanceStore.getMonthlyBalance(widget.year, widget.month);

    Future.microtask(() => getTransactionsStore(widget.year, widget.month));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<BaseState>(
      valueListenable: getTransactionsStore.state,
      builder: (context, snapshot, _) {
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Resumo com saldo anterior
                      ValueListenableBuilder<MonthlyBalanceModel>(
                        valueListenable: monthlyBalanceNotifier,
                        builder: (context, monthlyBalance, _) {
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Saldo anterior:',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ),
                                    VerticalDivider(),
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Previsto',
                                            style: Theme.of(context).textTheme.bodyMedium,
                                          ),
                                          Text(
                                            doubleToReal(monthlyBalance.previousExpectedBalance),
                                            style: Theme.of(context).textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                    VerticalDivider(),
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Realizado',
                                            style: Theme.of(context).textTheme.bodyMedium,
                                          ),
                                          Text(
                                            doubleToReal(monthlyBalance.previousRealizedBalance),
                                            style: Theme.of(context).textTheme.bodyMedium,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: DSButton(
                              text: 'Receita',
                              leftIcon: Icons.trending_up,
                              backgroundColor: Theme.of(context).colorScheme.surface,
                              textColor: Theme.of(context).colorScheme.onSurface,
                              onPressed: () async {
                                final result = await showModalBottomSheet<TransactionModel>(
                                  context: context,
                                  isScrollControlled: true,
                                  builder:
                                      (_) =>
                                          EditTransactionBottomSheet(type: TransactionType.income),
                                );
                                if (result != null) {
                                  // A atualização do saldo é feita automaticamente pelo store
                                }
                              },
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: DSButton(
                              text: 'Despesa',
                              rightIcon: Icons.trending_down,
                              backgroundColor: Theme.of(context).colorScheme.errorContainer,
                              textColor: Theme.of(context).colorScheme.onSurface,
                              onPressed: () async {
                                final result = await showModalBottomSheet<TransactionModel>(
                                  context: context,
                                  isScrollControlled: true,
                                  builder:
                                      (_) =>
                                          EditTransactionBottomSheet(type: TransactionType.expense),
                                );
                                if (result != null) {
                                  // A atualização do saldo é feita automaticamente pelo store
                                }
                              },
                            ),
                          ),
                        ],
                      ),

                      /// Entradas
                      TransactionsComponent(
                        year: widget.year,
                        month: widget.month,
                        type: TransactionType.income,
                      ),

                      /// Saídas
                      TransactionsComponent(
                        year: widget.year,
                        month: widget.month,
                        type: TransactionType.expense,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(color: Colors.green),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ValueListenableBuilder<MonthlyBalanceModel>(
                valueListenable: monthlyBalanceNotifier,
                builder: (context, monthlyBalance, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              'Saldo Previsto',
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(color: Colors.white),
                            ),
                          ),
                          Text(
                            doubleToReal(monthlyBalance.finalExpectedBalance),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              'Realizado',
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(color: Colors.white),
                            ),
                          ),
                          Text(
                            doubleToReal(monthlyBalance.finalRealizedBalance),
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).padding.bottom),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
