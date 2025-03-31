import 'package:cas_house/models/expanses.dart';
import 'package:cas_house/models/product_model.dart';
import 'package:flutter/material.dart';

class ShoppingListProvider extends ChangeNotifier {
  // Lista wydatków
  List<ProductModel> _shoppingList = [];

  // Getter dla listy wydatków
  List<ProductModel> get shoppingList => _shoppingList;

  // Dodawanie elementu do listy
  void addItem(ProductModel item) {
    _shoppingList.insert(0, item); // Dodaj element na początek listy
    notifyListeners(); // Powiadomienie listenerów o zmianie
  }

  // Aktualizacja stanu isBuy dla danego elementu
  void toggleIsBuy(int index) {
    if (index >= 0 && index < _shoppingList.length) {
      _shoppingList[index] = _shoppingList[index].copyWith(
        isBuy: !_shoppingList[index].isBuy, // Zmiana stanu isBuy
      );
      notifyListeners(); // Powiadomienie listenerów o zmianie
    }
  }
}
