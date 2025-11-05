import 'dart:io';
import 'package:cas_house/api_service.dart';
import 'package:cas_house/main_global.dart';
import 'package:cas_house/models/defect.dart';
import 'package:cas_house/providers/defects_provider.dart';
import 'package:cas_house/widgets/fullscreen_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

class DefectDetails extends StatefulWidget {
  final Defect defect;
  final DefectsProvider defectsProvider;

  const DefectDetails(
      {super.key, required this.defect, required this.defectsProvider});

  @override
  State<DefectDetails> createState() => _DefectDetailsState();
}

class _DefectDetailsState extends State<DefectDetails>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  static const String urlPrefix = ApiService.baseUrl;

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

  Future<void> _openMapWithAddress(String address) async {
    final encodedAddress = Uri.encodeComponent(address);
    final url = Platform.isIOS
        ? 'http://maps.apple.com/?q=$encodedAddress'
        : 'https://www.google.com/maps/search/?api=1&query=$encodedAddress';
    final uri = Uri.parse(url);

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nie można otworzyć map.")),
      );
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "-";
    return DateFormat('dd.MM.yyyy, HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final defect = widget.defect;
    final mainImage = (defect.imageFilenames?.isNotEmpty ?? false)
        ? "$urlPrefix/uploads/${defect.imageFilenames!.first}"
        : null;

    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              // 🔹 Główne zdjęcie defektu
              mainImage != null
                  ? Image.network(
                      mainImage,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: double.infinity,
                      height: 250,
                      color: Colors.grey[300],
                      child: const Icon(Icons.build,
                          size: 80, color: Colors.white),
                    ),

              // 🔹 Powrót
              Positioned(
                top: 40,
                left: 16,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.arrow_back, color: Colors.black),
                  ),
                ),
              ),

              // 🔹 Otwórz mapę
              if (defect.property?.location != null)
                Positioned(
                  top: 40,
                  right: 80,
                  child: IconButton(
                    onPressed: () =>
                        _openMapWithAddress(defect.property!.location),
                    icon: const CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.map, color: Colors.black)),
                  ),
                ),

              // 🔹 Status defektu – klikany z wyborem
              Positioned(
                top: 48,
                right: 16,
                child: GestureDetector(
                  onTap: _showStatusPicker,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 23,
                          height: 23,
                          decoration: BoxDecoration(
                            color: statusColor(widget.defect.status),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down,
                            size: 25, color: Colors.black54),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 🔹 Status i data
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                const Spacer(),
                Text(
                  _formatDate(defect.createdAt),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 🔹 Tytuł defektu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              defect.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 🔹 Zakładki
          TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            tabs: const [
              Tab(text: "Szczegóły"),
              Tab(text: "Zdjęcia"),
            ],
          ),

          // 🔹 Widok zakładek
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDetailsTab(),
                _buildImagesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    final d = widget.defect;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _detailItem("Opis", d.description),
          if (d.property != null) ...[
            const SizedBox(height: 16),
            const Text("Mieszkanie:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _detailItem("Nazwa", d.property!.name),
            _detailItem("Lokalizacja", d.property!.location),
          ],
          const SizedBox(height: 16),
          _detailItem("Zaktualizowano", _formatDate(d.updatedAt)),
        ],
      ),
    );
  }

  Widget _buildImagesTab() {
    final images = widget.defect.imageFilenames ?? [];
    if (images.isEmpty) {
      return const Center(child: Text("Brak zdjęć"));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final imageUrl = "$urlPrefix/uploads/${images[index]}";
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FullscreenImageViewer(
                  images: images,
                  initialIndex: index,
                ),
              ),
            );
          },
          child: Hero(
            tag: imageUrl,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("$title:", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _copyableItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text("$title: $value", style: const TextStyle(fontSize: 14)),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Skopiowano do schowka")),
              );
            },
          )
        ],
      ),
    );
  }

  void _showStatusPicker() {
    final statuses = [
      {'label': 'Nowy', 'color': Colors.red},
      {'label': 'W trakcie', 'color': Colors.orange},
      {'label': 'Naprawiony', 'color': Colors.green},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  "Zmień status defektu",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(height: 1),
              ...statuses.map((s) {
                return ListTile(
                  leading: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: s['color'] as Color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  title: Text(s['label'] as String),
                  onTap: () async {
                    final newStatus = s['label'] as String;

                    try {
                      setState(() {
                        widget.defect.status = newStatus;
                      });

                      // 🔹 aktualizacja backendu
                      await widget.defectsProvider
                          .updateStatus(widget.defect.id!, newStatus);

                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("Status zmieniono na: $newStatus")),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Błąd podczas zmiany statusu.")),
                      );
                    }
                  },
                );
              }).toList(),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}
