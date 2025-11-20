import 'dart:io';

import 'package:cas_house/api_service.dart';
import 'package:cas_house/main_global.dart';
import 'package:cas_house/models/properties.dart';
import 'package:cas_house/models/user.dart';
import 'package:cas_house/providers/properties_provider.dart';
import 'package:cas_house/sections/properties/add_new_property.dart';
import 'package:cas_house/sections/properties/add_tenant.dart';
import 'package:cas_house/sections/properties/property_detile_tabs/landlord_info.dart';
import 'package:cas_house/sections/properties/property_detile_tabs/rental_info.dart';
import 'package:cas_house/services/user_services.dart';
import 'package:cas_house/widgets/comfirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class PropertyDetails extends StatefulWidget {
  final Property property;
  final PropertiesProvider provider;
  const PropertyDetails(
      {super.key, required this.property, required this.provider});

  @override
  State<PropertyDetails> createState() => _PropertyDetailsState();
}

class PropertyProvider {}

class _PropertyDetailsState extends State<PropertyDetails>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Future<User?>? _otherUserFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final bool iAmOwner = loggedUser?.id == widget.property.ownerId;
    final String? otherUserId =
        iAmOwner ? widget.property.tenantId : widget.property.ownerId;

    if (otherUserId != null && otherUserId.isNotEmpty) {
      _otherUserFuture = UserServices().getUserById(otherUserId);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  static const String urlPrefix = ApiService.baseUrl;

  Future<void> openMapWithAddress(String address) async {
    final encodedAddress = Uri.encodeComponent(address);

    final url = Platform.isIOS
        ? 'http://maps.apple.com/?q=$encodedAddress'
        : 'https://www.google.com/maps/search/?api=1&query=$encodedAddress';

    final uri = Uri.parse(url);

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nie można otworzyć aplikacji map.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Image.network(
                "$urlPrefix/uploads/${widget.property.mainImage}",
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 40,
                left: 16,
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.arrow_back, color: Colors.black),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 0,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () =>
                          openMapWithAddress(widget.property.location),
                      icon: const CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.map, color: Colors.black)),
                    ),
                    if (loggedUser!.id == widget.property.ownerId)
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddTenant(
                                  propertyID: widget.property.id!,
                                  propertyPin: widget.property.pin),
                            ),
                          );
                        },
                        icon: const CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person_add, color: Colors.black)),
                      ),
                    if (loggedUser!.id == widget.property.ownerId)
                      IconButton(
                        onPressed: () => _showPropertyActions(context),
                        icon: const CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(Icons.settings, color: Colors.black)),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Column(
              children: [
                Text(widget.property.name,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                Text(widget.property.location)
              ],
            ),
          ),
          const SizedBox(height: 12),
          TabBar(
            controller: _tabController,
            overlayColor:
                WidgetStateProperty.all(LivoColors.brandGold.withOpacity(0.1)),
            indicatorColor: LivoColors.brandGold,
            labelColor: Colors.black,
            tabs: [
              const Tab(text: "Home"),
              const Tab(text: "Rentals info"),
              Tab(
                  text: loggedUser?.id == widget.property.ownerId
                      ? "Tenant"
                      : "Landlord"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMenuTab(),
                Center(
                  child: widget.property.status == "wynajęte"
                      ? RentalInfo(
                          property: widget.property, provider: widget.provider)
                      : const Text("Brak aktywnego najmu"),
                ),

                // 3. zakładka: Tenant / Landlord
                Builder(
                  builder: (_) {
                    final bool iAmOwner =
                        loggedUser?.id == widget.property.ownerId;
                    final String role = iAmOwner ? "Najemca" : "Właściciel";

                    if (_otherUserFuture == null) {
                      return Center(child: Text("Brak danych: $role"));
                    }

                    return FutureBuilder<User?>(
                      future: _otherUserFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data == null) {
                          return Center(
                              child: Text("Nie udało się pobrać: $role"));
                        }
                        final user = snapshot.data!;
                        return SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: PersonHeader(
                            user: user,
                            phone: null, // jeśli backend zwraca phone → przekaż
                            roleLabel: role,
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showPropertyActions(BuildContext context) {
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
                  "Zarządzaj nieruchomością",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(height: 1),

              // ✏️ Edytuj
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text("Edytuj dane mieszkania"),
                onTap: () {
                  Navigator.pop(context);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddNewProperty(
                            propertiesProvider: widget.provider,
                            property: widget.property)),
                  );
                },
              ),

              // 🗑️ Usuń
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Usuń mieszkanie"),
                onTap: () async {
                  Navigator.pop(context);

                  final confirmed = await showConfirmDialog(
                    context,
                    title: "Usuń nieruchomość",
                    message:
                        "Czy na pewno chcesz usunąć to mieszkanie?\nTej operacji nie można cofnąć.",
                    confirmText: "Usuń",
                    cancelText: "Anuluj",
                    confirmColor: Colors.red,
                  );

                  if (confirmed == true) {
                    try {
                      await widget.provider.deleteProperty(widget.property.id!);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Mieszkanie usunięte.")),
                        );
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text("Błąd podczas usuwania mieszkania.")),
                        );
                      }
                    }
                  }
                },
              ),

              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailItem("Powierzchnia", "${widget.property.size} m²"),
          _buildDetailItem("Pokoje", "${widget.property.rooms}"),
          _buildDetailItem("Piętro", "${widget.property.floor}"),
          _buildDetailItem("Status", widget.property.status),
          if (widget.property.status == "wynajęte")
            _buildDetailItem("Okres najmu",
                "${formatDate(widget.property.rentalStart!)} - ${formatDate(widget.property.rentalEnd!)}"),
          _buildDetailItem(
              "Czynsz", "${widget.property.rentAmount.toStringAsFixed(2)} zł"),
          _buildDetailItem("Kaucja",
              "${widget.property.depositAmount.toStringAsFixed(2)} zł"),
          _buildDetailItem("Cykl płatności", widget.property.paymentCycle),
          if (widget.property.features != null &&
              widget.property.features!.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                const Text("Dodatkowe cechy:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                for (var feature in widget.property.features!)
                  Text(feature, style: const TextStyle(color: Colors.black87)),
              ],
            ),
          if (widget.property.notes != null)
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: _buildDetailItem("Notatki", widget.property.notes!),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$title:', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: value));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Skopiowano do schowka")),
                      );
                    },
                    child: Text(value)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
