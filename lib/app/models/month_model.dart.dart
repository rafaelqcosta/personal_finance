class MonthModel {
  final int year; // Ano do mês
  final int month; // Mês
  final double initialBalance; // Saldo inicial
  final double finalBalance; // Saldo final
  final double initialBalanceExpected; // Saldo inicial Experado
  final double finalBalanceExpected; // Saldo final experado

  MonthModel({
    required this.year,
    required this.month,
    required this.initialBalance,
    required this.finalBalance,
    required this.initialBalanceExpected,
    required this.finalBalanceExpected,
  });

  factory MonthModel.fromJson(String id, Map<String, dynamic> json) => MonthModel(
    year: json['year'],
    month: json['month'],
    initialBalance: (json['initialBalance'] as num).toDouble(),
    finalBalance: (json['finalBalance'] as num).toDouble(),
    initialBalanceExpected: (json['initialBalanceExpected'] as num).toDouble(),
    finalBalanceExpected: (json['finalBalanceExpected'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {
    'year': year,
    'month': month,
    'initialBalance': initialBalance,
    'finalBalance': finalBalance,
    'finalBalanceExpected': finalBalanceExpected,
    'initialBalanceExpected': initialBalanceExpected,
  };

  MonthModel copyWith({
    double? initialBalance,
    double? finalBalance,
    DateTime? updatedAt,
    double? finalBalanceExpected,
    double? initialBalanceExpected,
  }) => MonthModel(
    year: year,
    month: month,
    initialBalance: initialBalance ?? this.initialBalance,
    finalBalance: finalBalance ?? this.finalBalance,
    initialBalanceExpected: initialBalanceExpected ?? this.initialBalanceExpected,
    finalBalanceExpected: finalBalanceExpected ?? this.finalBalanceExpected,
  );
}
