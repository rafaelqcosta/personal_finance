import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:personal_finance/app/core/utils/utils.dart';
import 'package:personal_finance/app/models/transaction_model.dart';
import 'package:personal_finance/app/mothly/ui/pages/components/transaction_details_bottom_sheet.dart';
import 'package:personal_finance/app/mothly/ui/stores/get_transactions_store.dart';

class TransactionsComponent extends StatefulWidget {
  final TransactionType type;
  final int year;
  final int month;

  const TransactionsComponent({
    super.key,
    required this.type,
    required this.year,
    required this.month,
  });

  @override
  State<TransactionsComponent> createState() => _TransactionsComponentState();
}

class _TransactionsComponentState extends State<TransactionsComponent> {
  final getTransactionsStore = Modular.get<GetTransactionsStore>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Cria uma cópia da lista original para não modificar o estado externo
    final sortedTransactions = List<TransactionModel>.from(
      widget.type == TransactionType.income
          ? getTransactionsStore.incomes
          : getTransactionsStore.expenses,
    )..sort((a, b) => a.dueDay.compareTo(b.dueDay));

    final totalExpected = sortedTransactions.fold<double>(
      0.0,
      (previous, element) => previous + element.expected,
    );

    final totalReceived = sortedTransactions.fold<double>(
      0.0,
      (previous, element) => previous + (element.realized),
    );
    return Card(
      child: ExpansionTile(
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        title: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  widget.type == TransactionType.income ? 'Entradas:' : 'Saídas:',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              VerticalDivider(),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Previsto', style: Theme.of(context).textTheme.bodyMedium),
                    Text(
                      doubleToReal(totalExpected),
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
                    Text('Realizado', style: Theme.of(context).textTheme.bodyMedium),
                    Text(
                      doubleToReal(totalReceived),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        children: [
          ...sortedTransactions.map((transaction) {
            return ListTile(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  showDragHandle: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (_) => TransactionDetailsBottomSheet(transaction: transaction),
                );
              },
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: iconFromTransactionType(transaction),
              title: Text(transaction.description),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${getTransactionTypeLabel(transaction)} ${getInstallmentProgress(transaction, widget.year, widget.month) ?? ''}',
                  ),
                  Text('Dia ${transaction.dueDay}'),
                ],
              ),
              trailing: Wrap(
                spacing: 32,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text('Previsto'), Text(doubleToReal(transaction.expected))],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [Text('Relalizado'), Text(doubleToReal(transaction.realized ?? 0))],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
