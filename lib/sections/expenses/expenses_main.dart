import 'package:cas_house/main_global.dart';
import 'package:cas_house/sections/expenses/expanse_tile.dart';
import 'package:cas_house/sections/expenses/history_of_expanses_popup.dart';

import 'package:cas_house/sections/expenses/summarize_expanse.dart';
import 'package:cas_house/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cas_house/models/expanses.dart';
import 'package:cas_house/providers/expanses_provider.dart';
import 'package:cas_house/sections/expenses/add_new_expanses_popup.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ExpensesSectionMain extends StatefulWidget {
  const ExpensesSectionMain({super.key});

  @override
  State<ExpensesSectionMain> createState() => _ExpensesSectionMainState();
}

class _ExpensesSectionMainState extends State<ExpensesSectionMain> {
  bool isLoading = false;
  int? currentMonth;
  int? currentYear;
  late ExpansesProvider provider;
  void fun() async {
    await provider.fetchExpensesForCurrentMonth();
    setState(() {});
  }

  void getByGroup(String date, String userId) async {
    await provider.fetchExpensesGroupedByCategory(date, userId);
  }

  @override
  void initState() {
    setState(() {
      isLoading = true;
    });
    provider = Provider.of<ExpansesProvider>(context, listen: false);
    fun();
    DateTime now = DateTime.now();

    currentMonth = now.month;
    currentYear = now.year;
    setState(() {
      isLoading = false;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final expansesProvider =
        Provider.of<ExpansesProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(4),
          child: Divider(),
        ),
        title: const Text('Expenses'),
        actions: <Widget>[
          IconButton(
            icon: Icon(MdiIcons.history),
            tooltip: 'History of expanses',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HistoryOfExpensesPopup(
                  expansesProvider: expansesProvider,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(MdiIcons.plus),
            tooltip: 'Add expenses',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddNewExpensesPopup(
                  expensesProvider: expansesProvider,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$currentMonth-$currentYear",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.summarize),
                tooltip: 'Summarize',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => SummarizeExpensesPopup(
                          expansesProvider: expansesProvider,
                          date: "$currentYear-$currentMonth")),
                ),
              ),
            ],
          ),
          isLoading
              ? const Center(child: LoadingWidget())
              : expansesProvider.expansesListThisMounth.isEmpty
                  ? const Center(child: Text('No expenses found.'))
                  : Expanded(
                      child: ListView.builder(
                        itemCount:
                            expansesProvider.expansesListThisMounth.length,
                        itemBuilder: (context, index) {
                          final item =
                              expansesProvider.expansesListThisMounth[index];
                          return ExpenseTile(
                            provider: expansesProvider,
                            expanse: item,
                          );
                        },
                      ),
                    ),
        ],
      ),
    );
  }
}
