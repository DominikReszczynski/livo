import 'package:auto_size_text/auto_size_text.dart';
import 'package:cas_house/main_global.dart';
import 'package:cas_house/providers/defects_provider.dart';
import 'package:cas_house/providers/properties_provider.dart';
import 'package:cas_house/widgets/animated_background.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeSectionMain extends StatefulWidget {
  const HomeSectionMain({super.key});
  @override
  State<HomeSectionMain> createState() => _HomeSectionMainState();
}

class _HomeSectionMainState extends State<HomeSectionMain>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    // Bezpiecznie po pierwszym framie:
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = loggedUser?.id;
      final defects = context.read<DefectsProvider>();
      final properties = context.read<PropertiesProvider>();
      if (userId != null) {
        defects.fetchDefects();
        properties.getAllPropertiesByOwner();
        properties.getAllPropertiesByTenant();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // (opcjonalnie) jeśli w trakcie życia ekranu zaloguje się user:
    final userId = loggedUser?.id;
    if (userId != null) {
      Future.microtask(
          () => context.read<DefectsProvider>().fetchForUser(userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final username = loggedUser?.username ?? 'User';

    // ⬇️ Nasłuchuj zmian:
    final defectsProvider = context.watch<DefectsProvider>();
    final propertiesProvider = context.watch<PropertiesProvider>();

    final premisesCount = propertiesProvider.propertiesListOwner.length;
    final rentalsCount = propertiesProvider.propertiesListTenant.length;

    return AnimatedBackground(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          children: [
            // Logo
            Center(
              child: Image.asset('assets/images/livo_logo.webp', height: 44),
            ),
            const SizedBox(height: 10),

            // Powitanie
            AutoSizeText(
              'Hi, $username',
              maxLines: 1,
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),

            // Statystyki: 2 kafelki
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Your properties',
                    value: premisesCount.toString(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Your rentals',
                    value: rentalsCount.toString(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Karta: Defects
            Card(
              elevation: 0,
              color: LivoColors.brandBeige,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Defects',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    const Divider(height: 1),
                    const SizedBox(height: 10),
                    if (defectsProvider.defects.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'No items yet',
                          style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(.6),
                          ),
                        ),
                      )
                    else
                      Column(
                        children: [
                          for (final d in defectsProvider.defects) ...[
                            _DefectChip(
                                item: _DefectItem(
                                    title: d.title,
                                    daysLeft: DateTime.now()
                                        .difference(
                                            (d.updatedAt ?? d.createdAt)!)
                                        .inDays,
                                    status: d.status)),
                            const SizedBox(height: 10),
                          ]
                        ],
                      ),
                  ],
                ),
              ),
            ),

            // ⛔ „Upcoming” na razie pomijamy – dodamy, gdy będą płatności/umowy.
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// Kafelek statystyki (duża liczba, mały tytuł)
class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      // elevation: 1.5,
      // shadowColor: Colors.black12,
      color: LivoColors.brandBeige,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: theme.textTheme.bodySmall?.color?.withOpacity(.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Model pozycji „defect”
class _DefectItem {
  final String title;
  final int daysLeft;
  final String status;
  const _DefectItem(
      {required this.title, required this.daysLeft, required this.status});
}

/// Jeden „chip” w liście Defects
class _DefectChip extends StatelessWidget {
  final _DefectItem item;
  const _DefectChip({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: LivoColors.background,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              blurRadius: 6, offset: Offset(0, 2), color: Color(0x14000000))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: statusColor(item.status),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: LivoColors.backgroundSecond,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${item.daysLeft} days',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
