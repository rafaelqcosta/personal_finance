import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal_finance/app/core/design_system/ds_colors.dart';
import 'package:personal_finance/app/core/design_system/ds_icons.dart';
import 'package:personal_finance/app/models/expense_model.dart';
import 'package:personal_finance/app/models/income_model.dart';
import 'package:personal_finance/app/models/transaction_model.dart';

String capitalize(String text) {
  if (text.isEmpty) return '';
  return text[0].toUpperCase() + text.substring(1).toLowerCase();
}

String doubleToReal(double value) {
  final NumberFormat formatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );
  String formated = formatter.format(value);
  return formated.replaceAll(' ', '');
}

String dateToString(DateTime date) {
  return DateFormat('dd/MM/yyyy').format(date);
}

Icon iconFromTransactionType(TransactionModel transaction) {
  return Icon(
    transaction.formType == TransactionFormType.parcelada
        ? DSIcons.installment
        : transaction.formType == TransactionFormType.recorrente
        ? DSIcons.recurrent
        : DSIcons.variable,
    color:
        transaction is ExpenseModel
            ? transaction.formType == TransactionFormType.parcelada
                ? DSColors.expenseInstallment
                : transaction.formType == TransactionFormType.recorrente
                ? DSColors.expenseFixed
                : DSColors.expenseVariable
            : transaction is IncomeModel && transaction.formType == TransactionFormType.recorrente
            ? DSColors.incomeFixed
            : DSColors.incomeVariable,
  );
}

int getCurrentInstallment(DateTime updateAt, int year, int month) {
  final monthsDifference = (year - updateAt.year) * 12 + (month - updateAt.month);
  return monthsDifference + 1; // +1 porque a 1ª parcela é no mês de updateAt
}

String getTransactionTypeLabel(TransactionModel transaction) {
  if (transaction is ExpenseModel && transaction.formType == TransactionFormType.parcelada) {
    return 'Parcelada';
  } else if (transaction.formType == TransactionFormType.unica) {
    return 'Única';
  } else {
    return 'Recorrente';
  }
}

String? getInstallmentProgress(TransactionModel transaction, int year, int month) {
  if (transaction is ExpenseModel &&
      transaction.formType == TransactionFormType.parcelada &&
      transaction.totalInstallments != null) {
    final current = getCurrentInstallment(transaction.updateAt, year, month);
    return '$current de ${transaction.totalInstallments}';
  }
  return null;
}
