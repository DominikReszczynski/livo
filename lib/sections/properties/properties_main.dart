import 'package:cas_house/sections/properties/add_new_property.dart';
import 'package:cas_house/sections/properties/property_tile.dart';

import 'package:cas_house/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cas_house/providers/properties_provider.dart';
import 'package:cas_house/sections/properties/add_new_property_owner.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ExpensesSectionMain extends StatefulWidget {
  const ExpensesSectionMain({super.key});

  @override
  State<ExpensesSectionMain> createState() => _ExpensesSectionMainState();
}

class _ExpensesSectionMainState extends State<ExpensesSectionMain>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  int? currentMonth;
  int? currentYear;
  late PropertiesProvider provider;
  late TabController _tabController;
  void fun(int tabNumber) async {
    tabNumber == 0
        ? await provider.getAllPropertiesByOwner()
        : await provider.getAllPropertiesByTenant();
  }

  @override
  void initState() {
    setState(() {
      isLoading = true;
    });
    provider = Provider.of<PropertiesProvider>(context, listen: false);
    fun(0);
    DateTime now = DateTime.now();

    currentMonth = now.month;
    currentYear = now.year;
    setState(() {
      isLoading = false;
    });

    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final propertiesProvider =
        Provider.of<PropertiesProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(4),
          child: Divider(),
        ),
        title: const Text('Properties'),
        actions: <Widget>[
          IconButton(
            icon: Icon(MdiIcons.plus),
            tooltip: 'Add property',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AddNewProperty(
                  propertiesProvider: propertiesProvider,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            tabs: [
              Tab(text: "My properties"),
              Tab(text: "Rented properties"),
            ],
            onTap: (value) => fun(value),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                isLoading
                    ? const Center(child: LoadingWidget())
                    : propertiesProvider.propertiesListOwner.isEmpty
                        ? const Center(child: Text('No properies found.'))
                        : Expanded(
                            child: ListView.builder(
                              itemCount:
                                  propertiesProvider.propertiesListOwner.length,
                              itemBuilder: (context, index) {
                                final item = propertiesProvider
                                    .propertiesListOwner[index];
                                return PropertyTile(
                                  provider: propertiesProvider,
                                  property: item!,
                                );
                              },
                            ),
                          ),
                isLoading
                    ? const Center(child: LoadingWidget())
                    : propertiesProvider.propertiesListTenant.isEmpty
                        ? const Center(child: Text('No properies found.'))
                        : Expanded(
                            child: ListView.builder(
                              itemCount: propertiesProvider
                                  .propertiesListTenant.length,
                              itemBuilder: (context, index) {
                                final item = propertiesProvider
                                    .propertiesListTenant[index];
                                return PropertyTile(
                                  provider: propertiesProvider,
                                  property: item!,
                                );
                              },
                            ),
                          ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
