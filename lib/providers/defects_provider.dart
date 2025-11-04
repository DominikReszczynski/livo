import 'dart:io';

import 'package:cas_house/models/defect.dart';
import 'package:cas_house/services/defect_services.dart';
import 'package:flutter/material.dart';

class DefectsProvider extends ChangeNotifier {
  List<Defect> _defects = [];

  List<Defect> get defects => _defects;

  Future<void> addDefect(Defect defect, List<File> images) async {
    final newDefect = await DefectsService.addDefect(defect, images);
    _defects.add(newDefect);
    notifyListeners();
  }

  Future<void> fetchDefects() async {
    final fetched = await DefectsService.getAllDefects();
    _defects = fetched;
    notifyListeners();
  }
}
