import 'package:cas_house/providers/properties_provider.dart';
import 'package:cas_house/sections/defects/add_new_defect_form.dart';
import 'package:flutter/material.dart';

class AddNewDefect extends StatefulWidget {
  final PropertiesProvider propertiesProvider;
  const AddNewDefect({super.key, required this.propertiesProvider});

  @override
  State<AddNewDefect> createState() => _AddNewDefectState();
}

class _AddNewDefectState extends State<AddNewDefect>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dodaj defekt')),
      body: Column(
        children: [
          Expanded(
              child: AddNewDefectForm(
                  propertiesProvider: widget.propertiesProvider)),
        ],
      ),
    );
  }
}
