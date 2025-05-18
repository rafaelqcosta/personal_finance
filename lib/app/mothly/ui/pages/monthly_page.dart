import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:personal_finance/app/core/utils/utils.dart';
import 'package:personal_finance/app/mothly/ui/pages/monthly_dashboard.dart';

class MonthlyPage extends StatefulWidget {
  const MonthlyPage({super.key});

  @override
  State<MonthlyPage> createState() => _MonthlyPageState();
}

class _MonthlyPageState extends State<MonthlyPage> {
  final int year = DateTime.now().year;

  late final List<int> months;

  @override
  void initState() {
    super.initState();
    months = List.generate(12, (index) => index + 1);
  }

  final currentMonthIndex = DateTime.now().month - 1;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: months.length,
      initialIndex: currentMonthIndex,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Mensal $year'),
          bottom: TabBar(
            isScrollable: true,
            tabs:
                months.map((m) {
                  final monthName = DateFormat.MMMM('pt_BR').format(DateTime(0, m));
                  return Tab(text: capitalize(monthName));
                }).toList(),
          ),
        ),
        body: TabBarView(
          children:
              months.map((m) {
                return MonthlyDashboard(year: year, month: m);
              }).toList(),
        ),
      ),
    );
  }
}
