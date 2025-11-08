import 'package:cas_house/sections/properties/add_new_property.dart';
import 'package:cas_house/sections/properties/property_tile.dart';
import 'package:cas_house/widgets/animated_background.dart';
import 'package:cas_house/widgets/loading.dart';
import 'package:cas_house/widgets/togglebutton_custom.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cas_house/providers/properties_provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ExpensesSectionMain extends StatefulWidget {
  const ExpensesSectionMain({super.key});

  @override
  State<ExpensesSectionMain> createState() => _ExpensesSectionMainState();
}

class _ExpensesSectionMainState extends State<ExpensesSectionMain> {
  bool isLoading = false;
  bool showRentals = false;
  late PropertiesProvider provider;

  @override
  void initState() {
    super.initState();
    provider = Provider.of<PropertiesProvider>(context, listen: false);
    _initialLoad();
  }

  Future<void> _initialLoad() async {
    setState(() => isLoading = true);
    await _refresh();
    if (mounted) setState(() => isLoading = false);
  }

  /// Pull-to-refresh — bez przełączania globalnego spinnera ekranu.
  Future<void> _refresh() async {
    try {
      if (showRentals) {
        await provider.getAllPropertiesByTenant();
      } else {
        await provider.getAllPropertiesByOwner();
      }
      if (mounted) setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nie udało się odświeżyć: $e')),
      );
    }
  }

  Future<void> _onToggle(bool rentalsSelected) async {
    if (showRentals == rentalsSelected) return;
    setState(() => showRentals = rentalsSelected);
    setState(() => isLoading = true);
    await _refresh();
    if (mounted) setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final propertiesProvider =
        Provider.of<PropertiesProvider>(context, listen: true);

    return AnimatedBackground(
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: PremisesRentalsToggle(
                      isRentals: showRentals,
                      onToggle: _onToggle,
                      firstText: 'Your properties',
                      secondText: 'Your rentals',
                    ),
                  ),
                  IconButton(
                    icon: Icon(MdiIcons.plus),
                    tooltip: 'Add property',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AddNewProperty(propertiesProvider: provider),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: LoadingWidget())
                  : RefreshIndicator.adaptive(
                      onRefresh: _refresh,
                      child: _buildSeparatedList(
                        showRentals,
                        propertiesProvider,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeparatedList(
      bool rentals, PropertiesProvider propertiesProvider) {
    final list = rentals
        ? propertiesProvider.propertiesListTenant
        : propertiesProvider.propertiesListOwner;

    // RefreshIndicator wymaga przewijalnego dziecka — nawet gdy pusto.
    if (list.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(child: Text('No properties found.')),
          SizedBox(height: 400),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = list[index]!;
        return PropertyTile(provider: provider, property: item);
      },
    );
  }
}
