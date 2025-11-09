import 'package:cas_house/providers/defects_provider.dart';
import 'package:cas_house/providers/properties_provider.dart';
import 'package:cas_house/sections/defects/add_new_defect.dart';
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
    _initialLoad();
  }

  Future<void> _initialLoad() async {
    setState(() => isLoading = true);
    await _refresh();
    if (mounted) setState(() => isLoading = false);
  }

  /// Pull-to-refresh – lekko, bez globalnego spinnera ekranu.
  Future<void> _refresh() async {
    try {
      await defectsProvider.fetchDefects();
      if (mounted) setState(() {}); // odśwież widok po pobraniu
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nie udało się odświeżyć: $e')),
      );
    }
  }

  void _onToggle(bool solvedSelected) {
    if (showSolved == solvedSelected) return;
    setState(() => showSolved = solvedSelected);
    // Nie pobieramy ponownie — filtrujemy lokalnie. Użytkownik może przeciągnąć, by pobrać.
  }

  @override
  Widget build(BuildContext context) {
    final defects = Provider.of<DefectsProvider>(context, listen: true).defects;

    // Filtrowanie po statusie
    final filtered = defects.where((d) {
      final status = (d.status ?? '').toString().toLowerCase();
      if (showSolved) {
        return status == 'naprawiony' || status == 'solved';
      } else {
        return status == 'nowy' ||
            status == 'w trakcie' ||
            status == 'in progress';
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
                          propertiesProvider: propertiesProvider,
                        ),
                      ),
                    ).then((_) => _refresh()),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// 🔹 Lista defektów / loader + pull-to-refresh
            Expanded(
              child: isLoading
                  ? const Center(child: LoadingWidget())
                  : RefreshIndicator.adaptive(
                      onRefresh: _refresh,
                      child: _buildDefectsList(filtered),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefectsList(List defects) {
    // RefreshIndicator wymaga przewijalnego dziecka — nawet gdy pusto.
    if (defects.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(child: Text('No defects found.')),
          SizedBox(height: 400), // trochę „powietrza”, by łatwo pociągnąć
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
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
