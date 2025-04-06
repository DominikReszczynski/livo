import 'dart:io';

import 'package:cas_house/models/expanses.dart';
import 'package:cas_house/models/properties.dart';
import 'package:cas_house/services/property_services.dart';
import 'package:flutter/material.dart';

class PropertiesProvider extends ChangeNotifier {
  List<Property?> _propertiesList = [];

  List<Property?> get propertiesList => _propertiesList;

  Future<void> getAllPropertiesByOwner() async {
    try {
      final List<Property?>? result =
          await PropertyServices().getAllPropertiesByOwner();
      if (result != null) {
        _propertiesList = result;
      }
    } catch (e) {
      print("Error fetching expenses: $e");
    } finally {
      notifyListeners();
    }
  }

  Future<bool> addProperty(Property property, File? imageFile) async {
    try {
      final result = await PropertyServices().addProperty(property, imageFile);
      if (result != null) {
        print('-------------');
        print(result);
        _propertiesList.insert(0, result);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print("Error adding property: $e");
      return false;
    }
    return false;
  }
}
