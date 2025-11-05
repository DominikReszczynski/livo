import 'package:cas_house/providers/defects_provider.dart';
import 'package:cas_house/providers/properties_provider.dart';
import 'package:cas_house/sections/defects/add_new_property.dart';
import 'package:cas_house/sections/defects/components/defects_tile.dart';
import 'package:cas_house/widgets/animated_background.dart';
import 'package:cas_house/widgets/loading.dart';
import 'package:cas_house/widgets/togglebutton_custom.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class DefectsMain extends StatefulWidget {
  const DefectsMain({super.key});

  @override
  State<DefectsMain> createState() => _DefectsMainState();
}

class _DefectsMainState extends State<DefectsMain> {
  bool isLoading = false;
  bool showSolved = false; // false = in progress, true = solved
  late DefectsProvider defectsProvider;
  late PropertiesProvider propertiesProvider;

  @override
  void initState() {
    super.initState();
    defectsProvider = Provider.of<DefectsProvider>(context, listen: false);
    propertiesProvider =
        Provider.of<PropertiesProvider>(context, listen: false);
    _loadDefects();
  }

  Future<void> _loadDefects() async {
    setState(() => isLoading = true);
    await defectsProvider.fetchDefects();
    setState(() => isLoading = false);
  }

  void _onToggle(bool solvedSelected) {
    if (showSolved == solvedSelected) return;
    setState(() => showSolved = solvedSelected);
  }

  @override
  Widget build(BuildContext context) {
    final defects = Provider.of<DefectsProvider>(context).defects;

    // Filtrowanie po statusie
    final filtered = defects.where((d) {
      if (showSolved) {
        return d.status.toLowerCase() == 'naprawiony' ||
            d.status.toLowerCase() == 'solved';
      } else {
        return d.status.toLowerCase() == 'nowy' ||
            d.status.toLowerCase() == 'w trakcie' ||
            d.status.toLowerCase() == 'in progress';
      }
    }).toList();

    return AnimatedBackground(
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            /// 🔹 Górny pasek z przyciskiem dodania defektu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: PremisesRentalsToggle(
                      isRentals: showSolved,
                      onToggle: _onToggle,
                      firstText: 'In progress',
                      secondText: 'Solved',
                    ),
                  ),
                  IconButton(
                    icon: Icon(MdiIcons.plus),
                    tooltip: 'Add defect',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddNewDefect(
                            propertiesProvider: propertiesProvider),
                      ),
                    ).then((_) => _loadDefects()),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// 🔹 Lista defektów lub loader
            Expanded(
              child: isLoading
                  ? const Center(child: LoadingWidget())
                  : _buildDefectsList(filtered),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefectsList(List defects) {
    if (defects.isEmpty) {
      return const Center(child: Text('No defects found.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      itemCount: defects.length,
      separatorBuilder: (_, __) => const SizedBox(height: 2),
      itemBuilder: (context, index) {
        final defect = defects[index];
        return DefectsTile(defect: defect, defectsProvider: defectsProvider);
      },
    );
  }
}
