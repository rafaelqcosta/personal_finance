import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:personal_finance/app/core/design_system/ds_button.dart';
import 'package:personal_finance/app/core/design_system/ds_dropdown_button.dart';
import 'package:personal_finance/app/core/design_system/ds_loading.dart';
import 'package:personal_finance/app/core/design_system/ds_snack_bar.dart';
import 'package:personal_finance/app/core/design_system/ds_text_field.dart';
import 'package:personal_finance/app/models/expense_model.dart';
import 'package:personal_finance/app/models/income_model.dart';
import 'package:personal_finance/app/models/transaction_model.dart';
import 'package:personal_finance/app/mothly/ui/stores/create_new_transaction_store.dart';
import 'package:personal_finance/app/mothly/ui/stores/get_transactions_store.dart';
import 'package:personal_finance/app/mothly/ui/stores/update_transaction_store.dart';

class EditTransactionBottomSheet extends StatefulWidget {
  final TransactionModel? transaction;
  final TransactionType type;

  const EditTransactionBottomSheet({super.key, this.transaction, required this.type});

  @override
  State<EditTransactionBottomSheet> createState() => _EditTransactionBottomSheetState();
}

class _EditTransactionBottomSheetState extends State<EditTransactionBottomSheet> {
  late final TextEditingController _descriptionController;
  late final TextEditingController _expectedController;
  late final TextEditingController _categoryController;
  final TextEditingController _installmentsController = TextEditingController();
  final createNewTransaction = Modular.get<CreateNewTransactionStore>();
  final updateTransaction = Modular.get<UpdateTransactionStore>();
  final getTransactionsStore = Modular.get<GetTransactionsStore>();

  late int _dueDay;
  late TransactionFormType _transactionFormType;
  String? _selectedCreditCardId;
  bool onlyOneTransaction = true;

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;

    _descriptionController = TextEditingController(text: transaction?.description ?? '');
    _expectedController = TextEditingController(
      text: transaction?.expected.toStringAsFixed(2) ?? '',
    );
    _categoryController = TextEditingController(
      text: transaction is ExpenseModel ? transaction.category : '',
    );
    _dueDay = transaction?.dueDay ?? DateTime.now().day;

    _transactionFormType = transaction?.formType ?? TransactionFormType.unica;
    if (transaction is ExpenseModel) {
      _selectedCreditCardId = transaction.creditCardId;
      final totalInstallments = transaction.totalInstallments;
      if (totalInstallments != null) {
        _installmentsController.text = totalInstallments.toStringAsFixed(2).replaceAll('.', ',');
      }
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _expectedController.dispose();
    _categoryController.dispose();
    _installmentsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isEditing = widget.transaction != null;
    final isExpense = widget.type == TransactionType.expense;
    final id = isEditing ? widget.transaction!.id : UniqueKey().toString();

    final expected = double.tryParse(_expectedController.text.replaceAll(',', '.')) ?? 0.0;
    final description = _descriptionController.text.trim();
    final totalInstallments = int.tryParse(_installmentsController.text);

    final isParcelada = _transactionFormType == TransactionFormType.parcelada;

    TransactionModel newTransaction;

    if (isExpense) {
      newTransaction = ExpenseModel(
        id: id,
        year: DateTime.now().year,
        month: DateTime.now().month,
        description: description,
        expected: expected,
        realized: isEditing ? widget.transaction!.realized : 0.0,
        dueDay: _dueDay,
        formType: _transactionFormType,
        category: _categoryController.text.trim(),
        totalInstallments: isParcelada ? totalInstallments : null,
        creditCardId: _selectedCreditCardId,
        updateAt: DateTime.now(),
        type: TransactionType.expense,
      );
    } else {
      newTransaction = IncomeModel(
        id: id,
        year: DateTime.now().year,
        month: DateTime.now().month,
        description: description,
        expected: expected,
        realized: isEditing ? widget.transaction!.realized : 0.0,
        dueDay: _dueDay,
        formType: _transactionFormType,
        updateAt: DateTime.now(),
        type: TransactionType.income,
      );
    }
    DSLoading().show();
    if (widget.transaction == null) {
      await createNewTransaction(newTransaction);
    } else {
      await updateTransaction(transaction: newTransaction, onlyOneTransaction: onlyOneTransaction);
    }
    await getTransactionsStore(newTransaction.year, newTransaction.month);

    DSLoading().hide();

    if (createNewTransaction.failure.value != null || updateTransaction.failure.value != null) {
      DSSnackbar.showError(
        createNewTransaction.failure.value?.message ??
            updateTransaction.failure.value?.message ??
            'Erro ao salvar transação',
      );
      return;
    } else {
      DSSnackbar.showSuccess('Transação salva com sucesso');
      Navigator.of(context).pop(newTransaction);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.transaction != null;
    final isExpense = widget.type == TransactionType.expense;

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              isEditing
                  ? (isExpense ? 'Editar Despesa' : 'Editar Receita')
                  : (isExpense ? 'Nova Despesa' : 'Nova Receita'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            DSTextField(controller: _descriptionController, label: 'Descrição'),
            const SizedBox(height: 16),

            if (isExpense) ...[
              DSTextField(controller: _categoryController, label: 'Categoria'),
              const SizedBox(height: 16),
            ],

            Row(
              children: [
                Expanded(
                  child: DSTextField(
                    controller: _expectedController,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    label: 'Valor Previsto',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DSDropdownButtonFormField<int>(
                    value: _dueDay,
                    label: 'Vencimento (dia)',
                    items: List.generate(
                      31,
                      (i) => DropdownMenuItem(value: i + 1, child: Text('Dia ${i + 1}')),
                    ),
                    onChanged: (v) {
                      if (v != null) setState(() => _dueDay = v);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            DSDropdownButtonFormField<TransactionFormType>(
              value: _transactionFormType,
              label: 'Tipo de Transação',
              items: [
                DropdownMenuItem(value: TransactionFormType.unica, child: Text('Única')),
                DropdownMenuItem(value: TransactionFormType.recorrente, child: Text('Recorrente')),
                if (isExpense)
                  DropdownMenuItem(value: TransactionFormType.parcelada, child: Text('Parcelada')),
              ],
              onChanged: (v) {
                if (v != null) {
                  setState(() {
                    _transactionFormType = v;
                    if (_transactionFormType != TransactionFormType.parcelada) {
                      _installmentsController.clear();
                    }
                  });
                }
              },
            ),

            const SizedBox(height: 16),
            if (_transactionFormType == TransactionFormType.parcelada)
              DSTextField(
                controller: _installmentsController,
                keyboardType: TextInputType.number,
                label: 'Número de Parcelas',
              ),

            if (_transactionFormType == TransactionFormType.parcelada) const SizedBox(height: 16),

            if (isExpense)
              DSDropdownButtonFormField<String>(
                value: _selectedCreditCardId,
                label: 'Cartão de Crédito (opcional)',
                items: const [
                  DropdownMenuItem(value: 'nubank', child: Text('Nubank')),
                  DropdownMenuItem(value: 'inter', child: Text('Inter')),
                  DropdownMenuItem(value: 'c6', child: Text('C6 Bank')),
                ],
                onChanged: (v) => setState(() => _selectedCreditCardId = v),
              ),

            const SizedBox(height: 24),
            DSButton(
              onPressed: () {
                if (_transactionFormType != TransactionFormType.unica && isEditing) {
                  _typeEditDialog();
                } else {
                  _submit();
                }
              },
              text: isEditing ? 'Salvar' : 'Criar',
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Future<void> _typeEditDialog() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar transação recorrente'),
          content: const Text(
            'Você está editando uma transação recorrente ou parcelada.\n\n'
            'Deseja aplicar a alteração apenas para este mês ou a partir deste mês para os próximos?',
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actionsOverflowDirection: VerticalDirection.down,
          actionsOverflowButtonSpacing: 8,
          actionsOverflowAlignment: OverflowBarAlignment.end,
          actions: [
            DSButton(
              onPressed: () {
                onlyOneTransaction = true;
                Modular.to.pop();
                _submit();
              },
              text: 'Mês atual',
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              textColor: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            DSButton(
              onPressed: () {
                onlyOneTransaction = false;
                Modular.to.pop();
                _submit();
              },
              text: 'A partir de hoje',
            ),
          ],
        );
      },
    );
  }
}
