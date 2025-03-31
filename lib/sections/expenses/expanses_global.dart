// Funkcja pomocnicza do pobrania ikony na podstawie kategorii
import 'package:cas_house/sections/expenses/add_new_expanses_popup.dart';
import 'package:flutter/material.dart';

IconData getCategoryIcon(ExpenseCategory category) {
  switch (category) {
    case ExpenseCategory.food:
      return Icons.fastfood;
    case ExpenseCategory.housing:
      return Icons.home;
    case ExpenseCategory.utilities:
      return Icons.lightbulb;
    case ExpenseCategory.transportation:
      return Icons.directions_car;
    case ExpenseCategory.healthcare:
      return Icons.healing;
    case ExpenseCategory.entertainment:
      return Icons.movie;
    case ExpenseCategory.education:
      return Icons.school;
    case ExpenseCategory.personalCare:
      return Icons.person;
    case ExpenseCategory.clothing:
      return Icons.shopping_bag;
    case ExpenseCategory.savings:
      return Icons.savings;
    case ExpenseCategory.debtRepayment:
      return Icons.money_off;
    case ExpenseCategory.insurance:
      return Icons.security;
    case ExpenseCategory.miscellaneous:
      return Icons.more_horiz;
    default:
      return Icons.help;
  }
}

// Funkcja pomocnicza do konwersji enum na czytelną nazwę
String getCategoryName(ExpenseCategory category) {
  switch (category) {
    case ExpenseCategory.food:
      return 'Jedzenie';
    case ExpenseCategory.housing:
      return 'Mieszkanie';
    case ExpenseCategory.utilities:
      return 'Media';
    case ExpenseCategory.transportation:
      return 'Transport';
    case ExpenseCategory.healthcare:
      return 'Opieka zdrowotna';
    case ExpenseCategory.entertainment:
      return 'Rozrywka';
    case ExpenseCategory.education:
      return 'Edukacja';
    case ExpenseCategory.personalCare:
      return 'Pielęgnacja osobista';
    case ExpenseCategory.clothing:
      return 'Odzież';
    case ExpenseCategory.savings:
      return 'Oszczędności';
    case ExpenseCategory.debtRepayment:
      return 'Spłata długów';
    case ExpenseCategory.insurance:
      return 'Ubezpieczenie';
    case ExpenseCategory.miscellaneous:
      return 'Inne';
    default:
      return '';
  }
}

getCategoryNameFromString(String categoryNameFromBackend) {
  ExpenseCategory category = ExpenseCategory.values.firstWhere(
    (e) => e.toString() == categoryNameFromBackend,
    orElse: () => ExpenseCategory.miscellaneous,
  );
  String categoryName = getCategoryName(category);
  return categoryName;
}

getCategoryIconFromString(String categoryNameFromBackend) {
  ExpenseCategory category = ExpenseCategory.values.firstWhere(
    (e) => e.toString() == categoryNameFromBackend,
    orElse: () => ExpenseCategory.miscellaneous,
  );
  IconData categoryIcon = getCategoryIcon(category);
  return categoryIcon;
}
