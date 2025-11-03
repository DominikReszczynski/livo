import 'dart:io';

import 'package:flutter/material.dart';

class DefectsProvider extends ChangeNotifier {
  Future<void> addDefect(String propertyId, String title, String description,
      List<File> images) async {
    try {
      // Add your logic to add a defect here
    } catch (e) {
      print("Error fetching expenses: $e");
    } finally {
      notifyListeners();
    }
  }
}
