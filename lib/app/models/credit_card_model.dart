/// Metadados do cartão (pai da subcoleção `transactions`)
class CreditCardModel {
  final String id; // id
  final String name; // nome
  final int dueDay; // dia de vencimento
  final int closingDay; // fechamento da fatura

  CreditCardModel({
    required this.id,
    required this.name,
    required this.dueDay,
    required this.closingDay,
  });

  factory CreditCardModel.fromJson(Map<String, dynamic> json) => CreditCardModel(
    id: json['id'],
    name: json['name'],
    dueDay: json['dueDay'],
    closingDay: json['closingDay'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'dueDay': dueDay,
    'closingDay': closingDay,
  };
}
