import 'package:cas_house/models/properties.dart';
import 'package:cas_house/providers/properties_provider.dart';
import 'package:cas_house/sections/properties/add_new_property_owner.dart';
import 'package:cas_house/sections/properties/add_new_property_tenant.dart';
import 'package:flutter/material.dart';

class AddNewProperty extends StatefulWidget {
  final bool? result;
  final PropertiesProvider propertiesProvider;
  final Property? property;
  const AddNewProperty(
      {super.key,
      required this.propertiesProvider,
      this.result,
      this.property});

  @override
  State<AddNewProperty> createState() => _AddNewPropertyState();
}

class _AddNewPropertyState extends State<AddNewProperty>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(widget.property != null
              ? "Edytuj mieszkanie"
              : "Dodaj mieszkanie")),
      body: Column(
        children: [
          Expanded(
            child: widget.result == true && widget.result != null
                ? AddNewPropertyTenant(
                    propertiesProvider: widget.propertiesProvider)
                : AddNewPropertyOwner(
                    propertiesProvider: widget.propertiesProvider,
                    propertyToEdit: widget.property ?? widget.property),
          ),
        ],
      ),
    );
  }
}
