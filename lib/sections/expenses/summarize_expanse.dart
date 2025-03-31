import 'package:cas_house/main_global.dart';
import 'package:cas_house/sections/expenses/expanses_global.dart';
import 'package:flutter/material.dart';
import 'package:cas_house/providers/expanses_provider.dart';

class SummarizeExpensesPopup extends StatefulWidget {
  final ExpansesProvider expansesProvider;
  final String date;
  const SummarizeExpensesPopup({
    super.key,
    required this.expansesProvider,
    required this.date,
  });

  @override
  State<SummarizeExpensesPopup> createState() => _SummarizeExpensesPopupState();
}

class _SummarizeExpensesPopupState extends State<SummarizeExpensesPopup> {
  Map<String, dynamic>? summarizeMap;
  void getByGroup(String date, String userId) async {
    final result = await widget.expansesProvider
        .fetchExpensesGroupedByCategory(date, userId);
    print("result: $result");
    setState(() {
      summarizeMap = result;
    });
  }

  @override
  void initState() {
    getByGroup(widget.date, loggedUser!.id!);
    setState(() {});
    print(widget.date);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Summary for ${widget.date}'),
      ),
      body: summarizeMap == null
          ? const Center(child: Text("Brak danych do wyświetlenia"))
          : ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: summarizeMap!.length,
              itemBuilder: (context, index) {
                String key = summarizeMap!.keys.elementAt(index);
                dynamic value = summarizeMap![key];
                return ListTile(
                  title: Text('${getCategoryNameFromString(key)}'),
                  subtitle: Text('$value zł'),
                  leading: Icon(getCategoryIconFromString(key)),
                );
              },
            ),
    );
  }
}
