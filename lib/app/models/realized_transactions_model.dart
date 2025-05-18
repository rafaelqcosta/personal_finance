import 'package:personal_finance/app/models/transaction_model.dart';

class RealizedTransactionsModel {
  final int year; // Ano do mês
  final int month; // Mês
  final List<TransactionModel> transactions;

  RealizedTransactionsModel({required this.year, required this.month, required this.transactions});

  // factory RealizedTransactionsModel.fromMap(Map<String, dynamic> map) {
  //   return RealizedTransactionsModel(
  //     year: map['year']?.toInt() ?? 0,
  //     month: map['month']?.toInt() ?? 0,
  //     transactions: List<TransactionModel>.from(
  //         map['transactions']?.map((x) => TransactionModel.fromJson(x.))),
  //   );
  // }
}
