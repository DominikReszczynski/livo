import 'dart:io';
import 'package:cas_house/models/properties.dart';
import 'package:cas_house/services/property_services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PropertiesProvider extends ChangeNotifier {
  List<Property?> _propertiesListOwner = [];

  List<Property?> get propertiesListOwner => _propertiesListOwner;

  List<Property?> _propertiesListTenant = [];

  List<Property?> get propertiesListTenant => _propertiesListTenant;

  Future<void> getAllPropertiesByOwner() async {
    try {
      final List<Property?>? result =
          await PropertyServices().getAllPropertiesByOwner();
      if (result != null) {
        _propertiesListOwner = result;
      }
    } catch (e) {
      print("Error fetching expenses: $e");
    } finally {
      notifyListeners();
    }
  }

  Future getAllPropertiesByTenant() async {
    try {
      final List<Property?>? result =
          await PropertyServices().getAllPropertiesByTenant();
      if (result != null) {
        _propertiesListTenant = result;
        notifyListeners();

        return result;
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
        _propertiesListOwner.insert(0, result);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print("Error adding property: $e");
      return false;
    }
    return false;
  }

  Future<bool> updateProperty(Property property, File? newImage) async {
    try {
      final updatedProperty =
          await PropertyServices().updateProperty(property, newImage);

      if (updatedProperty == null) return false;

      // 🔹 Zaktualizuj dane w lokalnych listach
      bool updated = false;

      void _updateIn(List<Property?> list) {
        for (int i = 0; i < list.length; i++) {
          if (list[i]?.id == updatedProperty.id) {
            list[i] = updatedProperty;
            updated = true;
            break;
          }
        }
      }

      _updateIn(_propertiesListOwner);
      _updateIn(_propertiesListTenant);

      if (updated) {
        notifyListeners();
      }

      return true;
    } catch (e) {
      print('❌ Błąd podczas aktualizacji nieruchomości: $e');
      return false;
    }
  }

  Future<bool> deleteProperty(String propertyId) async {
    try {
      final result = await PropertyServices().deleteProperty(propertyId);
      if (result) {
        _propertiesListOwner.removeWhere((p) => p?.id == propertyId);
        _propertiesListTenant.removeWhere((p) => p?.id == propertyId);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print("❌ Error deleting property: $e");
    }
    return false;
  }

  Future addTenantToProperty(String propertyID, String pin,
      DateTime rentalStart, DateTime rentalEnd) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedUserId = prefs.getString('userId');
      final Property? result = await PropertyServices().addTenantToProperty(
          propertyID, pin, storedUserId!, rentalStart, rentalEnd);
      if (result != null) {
        _propertiesListTenant.insert(0, result);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print("Error adding tenant to property: $e");
      return false;
    }
    return false;
  }

  Future<bool> setPin(String propertyID, String pin) async {
    try {
      final result = await PropertyServices().setPin(propertyID, pin);
      if (result) {
        for (var property in _propertiesListOwner) {
          if (property!.id == propertyID) {
            property.pin = pin;
            break;
          }
        }
        notifyListeners();
        return true;
      }
    } catch (e) {
      print("Error setting PIN: $e");
      return false;
    }
    return false;
  }

  Future<bool> deletePin(String propertyID) async {
    try {
      final result = await PropertyServices().removePin(propertyID);
      if (result) {
        for (var property in _propertiesListOwner) {
          if (property!.id == propertyID) {
            property.pin = null;
            break;
          }
        }
        notifyListeners();
        return true;
      }
    } catch (e) {
      print("Error deleting PIN: $e");
      return false;
    }
    return false;
  }

  Future<bool> addRentalImagesToProperty(
      String propertyID, List<File> images) async {
    print(images.length);
    try {
      final newFilenames =
          await PropertyServices().addRentalImages(propertyID, images);
      if (newFilenames.isEmpty) {
        return false;
      }

      // helper do bezpiecznego dopięcia listy plików (bez duplikatów)
      void _appendTo(List<Property?> list) {
        for (final p in list) {
          if (p?.id == propertyID) {
            p!.imageFilenames ??= <String>[];
            for (final name in newFilenames) {
              if (!p.imageFilenames!.contains(name)) {
                p.imageFilenames!.add(name);
              }
            }
            break;
          }
        }
      }

      _appendTo(_propertiesListOwner);
      _appendTo(_propertiesListTenant);

      notifyListeners();
      return true;
    } catch (e) {
      print("Error adding rental images: $e");
      return false;
    }
  }
}
