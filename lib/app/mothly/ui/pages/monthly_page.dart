import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:intl/intl.dart';
import 'package:personal_finance/app/core/utils/utils.dart';
import 'package:personal_finance/app/mothly/ui/pages/monthly_dashboard.dart';
import 'package:personal_finance/app/mothly/ui/stores/monthly_balance_store.dart';

class MonthlyPage extends StatefulWidget {
  const MonthlyPage({super.key});

  @override
  State<MonthlyPage> createState() => _MonthlyPageState();
}

class _MonthlyPageState extends State<MonthlyPage> {
  final int year = DateTime.now().year;
  final ValueNotifier<int> currentMonthNotifier = ValueNotifier<int>(DateTime.now().month);
  late final List<int> months;
  late final MonthlyBalanceStore monthlyBalanceStore;

  @override
  void initState() {
    super.initState();
    months = List.generate(12, (index) => index + 1);
    monthlyBalanceStore = Modular.get<MonthlyBalanceStore>();

    // Adiciona listener para atualizar o saldo quando o mês mudar
    currentMonthNotifier.addListener(() {
      // Não é necessário chamar nada aqui, pois o MonthlyDashboard
      // já vai solicitar o saldo do mês quando for construído
    });
  }

  @override
  void dispose() {
    currentMonthNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: months.length,
      initialIndex: currentMonthNotifier.value - 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Mensal $year'),
          bottom: TabBar(
            isScrollable: true,
            onTap: (index) {
              // Atualiza o mês atual quando a tab muda
              currentMonthNotifier.value = index + 1;
            },
            tabs:
                months.map((m) {
                  final monthName = DateFormat.MMMM('pt_BR').format(DateTime(0, m));
                  return Tab(text: capitalize(monthName));
                }).toList(),
          ),
        ),
        body: ValueListenableBuilder<int>(
          valueListenable: currentMonthNotifier,
          builder: (context, currentMonth, _) {
            return TabBarView(
              children:
                  months.map((m) {
                    return MonthlyDashboard(year: year, month: m);
                  }).toList(),
            );
          },
        ),
      ),
    );
  }
}
