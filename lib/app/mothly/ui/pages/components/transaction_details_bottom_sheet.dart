import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:personal_finance/app/core/design_system/ds_button.dart';
import 'package:personal_finance/app/core/design_system/ds_icon_button.dart';
import 'package:personal_finance/app/core/design_system/ds_loading.dart';
import 'package:personal_finance/app/core/design_system/ds_snack_bar.dart';
import 'package:personal_finance/app/core/design_system/ds_text_field.dart';
import 'package:personal_finance/app/core/utils/utils.dart';
import 'package:personal_finance/app/models/expense_model.dart';
import 'package:personal_finance/app/models/transaction_model.dart';
import 'package:personal_finance/app/mothly/ui/pages/components/edit_transaction_bottom_sheet.dart';
import 'package:personal_finance/app/mothly/ui/stores/get_transactions_store.dart';
import 'package:personal_finance/app/mothly/ui/stores/update_transaction_store.dart';

class TransactionDetailsBottomSheet extends StatefulWidget {
  final TransactionModel transaction;

  const TransactionDetailsBottomSheet({super.key, required this.transaction});

  @override
  State<TransactionDetailsBottomSheet> createState() => _TransactionDetailsBottomSheetState();
}

class _TransactionDetailsBottomSheetState extends State<TransactionDetailsBottomSheet> {
  late TransactionModel transaction;
  final updateTransactionStore = Modular.get<UpdateTransactionStore>();
  final getTransactionsStore = Modular.get<GetTransactionsStore>();

  @override
  void initState() {
    transaction = widget.transaction;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction is ExpenseModel;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,

          children: [
            /// Header Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DSIconButton(
                  onPressed: () async {
                    final newTransaction = await showModalBottomSheet<TransactionModel>(
                      context: context,
                      isScrollControlled: true,
                      builder:
                          (_) => EditTransactionBottomSheet(
                            type: transaction.type,
                            transaction: transaction,
                          ),
                    );
                    if (newTransaction != null) {
                      setState(() {
                        transaction = newTransaction;
                      });
                    }
                  },
                  icon: Icons.edit,
                ),
                DSIconButton(onPressed: () => Modular.to.pop(), icon: Icons.close),
              ],
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    iconFromTransactionType(transaction),
                    const SizedBox(width: 8),
                    Text(getTransactionTypeLabel(transaction)),
                    const Spacer(),

                    Text(
                      getInstallmentProgress(transaction, transaction.year, transaction.month) ??
                          '',
                    ),
                  ],
                ),
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(transaction.description, style: Theme.of(context).textTheme.titleMedium),
                    if (isExpense) ...[
                      Text(
                        'Categoria: ${(transaction as ExpenseModel).category}',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ],

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.event, size: 16),
                        const SizedBox(width: 8),
                        Text('Vencimento dia ${transaction.dueDay}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text('Previsto'),
                          Text(doubleToReal(transaction.expected)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      backgroundColor:
                          transaction.realized != 0
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surface,
                    ),

                    onPressed: () => confirmValueDialog(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            transaction.realized != 0 ? 'Realizado' : 'Pendente',
                            style: TextStyle(
                              color: transaction.realized != 0 ? Colors.white : Colors.black,
                            ),
                          ),
                          if (transaction.realized != 0)
                            Text(
                              doubleToReal(transaction.realized),
                              style: TextStyle(
                                color: transaction.realized != 0 ? Colors.white : Colors.black,
                              ),
                            )
                          else
                            Text(
                              widget.transaction.type == TransactionType.income
                                  ? 'Confirmar receita'
                                  : 'Realizar pagamento',
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> confirmValueDialog() async {
    if (transaction.realized != 0) {
      DSLoading().show();
      transaction.realized = 0;
      await updateTransactionStore(onlyOneTransaction: true, transaction: transaction);

      getTransactionsStore(transaction.year, transaction.month);
      showLoadingAndRresult();
      return;
    }
    final controller = TextEditingController(
      text: transaction.expected.toStringAsFixed(2).replaceAll('.', ','),
    );

    showDialog<double>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmação de pagamento'),
          content: DSTextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            label: 'Valor pago',
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            DSButton(
              onPressed: () => Navigator.of(context).pop(null),
              text: 'Cancelar',
              backgroundColor: Theme.of(context).colorScheme.surface,
              textColor: Theme.of(context).colorScheme.onSurface,
            ),

            DSButton(
              onPressed: () async {
                Navigator.of(context);
                DSLoading().show();
                final value = double.tryParse(controller.text.replaceAll(',', '.'));
                transaction.realized = value ?? 0;
                await updateTransactionStore(onlyOneTransaction: true, transaction: transaction);

                getTransactionsStore(transaction.year, transaction.month);
              },
              text: 'Confirmar',
            ),
          ],
        );
      },
    );
  }

  void showLoadingAndRresult() {
    DSLoading().hide();

    if (updateTransactionStore.failure.value != null) {
      DSSnackbar.showError(
        updateTransactionStore.failure.value?.message ?? 'Erro ao salvar transação',
      );
      return;
    } else {
      setState(() {});
      DSSnackbar.showSuccess('Transação salva com sucesso');
    }
  }
}
