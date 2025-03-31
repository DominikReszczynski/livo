import 'package:cas_house/models/product_model.dart';
import 'package:cas_house/sections/shoppingList/components/category_and_priority_input.dart';
import 'package:cas_house/sections/shoppingList/components/price_and_currency_input.dart';
import 'package:cas_house/sections/shoppingList/components/quantity_and_unit_input.dart';
import 'package:flutter/material.dart';

class AddProductPopUp extends StatefulWidget {
  final Function(ProductModel) addProductFun;
  const AddProductPopUp({super.key, required this.addProductFun});

  @override
  State<AddProductPopUp> createState() => _AddProductPopUpState();
}

class _AddProductPopUpState extends State<AddProductPopUp> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _producerController = TextEditingController();
  final TextEditingController _shopController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String _selectedUnit = 'kg';
  String _selectedCurrency = 'USD';
  String _selectedCategory = 'Groceries';
  String _selectedPriority = 'Low';

  // Bezpieczne parsowanie double
  double parseSafeDouble(String value) {
    return double.tryParse(value) ?? 0.0;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _producerController.dispose();
    _shopController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              "Add Item to Shopping List",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Nazwa przedmiotu
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Item Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Producent
            TextField(
              controller: _producerController,
              decoration: const InputDecoration(
                labelText: "Producer",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Sklep
            TextField(
              controller: _shopController,
              decoration: const InputDecoration(
                labelText: "Shop",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Ilość i jednostka
            QuantityAndUnitInput(
              onQuantityChanged: (double quantity) {
                _quantityController.text = quantity.toString();
              },
              onUnitChanged: (String unit) {
                _selectedUnit = unit;
              },
            ),
            const SizedBox(height: 16),
            // Cena i waluta
            PriceAndCurrencyInput(
              onPriceChanged: (double price) {
                _priceController.text = price.toString();
              },
              onCurrencyChanged: (String currency) {
                _selectedCurrency = currency;
              },
            ),
            const SizedBox(height: 16),
            // Kategoria i priorytet
            CategoryAndPriorityInput(
              onCategoryChanged: (String category) {
                _selectedCategory = category;
              },
              onPriorityChanged: (String priority) {
                _selectedPriority = priority;
              },
            ),
            const SizedBox(height: 16),
            // Przycisk dodawania
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty &&
                    _quantityController.text.isNotEmpty &&
                    _priceController.text.isNotEmpty) {
                  final newProduct = ProductModel(
                    name: _nameController.text,
                    producent: _producerController.text,
                    shop: _shopController.text,
                    amount: parseSafeDouble(_quantityController.text),
                    unit: _selectedUnit,
                    price: parseSafeDouble(_priceController.text),
                    currency: _selectedCurrency,
                    category: _selectedCategory,
                    date: DateTime.now(),
                    isBuy: false,
                    priority: _selectedPriority,
                  );
                  widget.addProductFun(newProduct);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Please fill in all required fields.")),
                  );
                }
              },
              child: const Text("Add Item"),
            ),
          ],
        ),
      ),
    );
  }
}
