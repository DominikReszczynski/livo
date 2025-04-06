// Funkcja pomocnicza do pobrania ikony na podstawie kategorii
import 'package:cas_house/sections/properties/add_new_property_popup.dart';
import 'package:flutter/material.dart';

getCategoryNameFromString(String categoryNameFromBackend) {
  ExpenseCategory category = ExpenseCategory.values.firstWhere(
    (e) => e.toString() == categoryNameFromBackend,
    orElse: () => ExpenseCategory.miscellaneous,
  );
  // String categoryName = getCategoryName(category);
  // return categoryName;
}

getCategoryIconFromString(String categoryNameFromBackend) {
  ExpenseCategory category = ExpenseCategory.values.firstWhere(
    (e) => e.toString() == categoryNameFromBackend,
    orElse: () => ExpenseCategory.miscellaneous,
  );
  // IconData categoryIcon = getCategoryIcon(category);
  // return categoryIcon;
}
