class BalanceMonthModel {
  final int year;
  final int month;
  final double expected;
  final double realized;
  final double initial;
  final double finalBalance;

  BalanceMonthModel({
    required this.year,
    required this.month,
    required this.expected,
    required this.realized,
    required this.initial,
    required this.finalBalance,
  });
}
