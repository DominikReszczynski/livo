import 'package:cas_house/main_global.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:cas_house/models/expanses.dart';
import 'package:cas_house/providers/properties_provider.dart';

enum ExpenseCategory {
  food,
  housing,
  utilities,
  transportation,
  healthcare,
  entertainment,
  education,
  personalCare,
  clothing,
  savings,
  debtRepayment,
  insurance,
  miscellaneous,
}

class AddNewExpensesPopup extends StatefulWidget {
  const AddNewExpensesPopup(
      {super.key, required PropertiesProvider expensesProvider});

  @override
  State<AddNewExpensesPopup> createState() => _AddNewExpensesPopupState();
}

class _AddNewExpensesPopupState extends State<AddNewExpensesPopup> {
  final TextEditingController _expenseNameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _expenseDescriptionController =
      TextEditingController();
  final TextEditingController _placeOfPurchase = TextEditingController();

  ExpenseCategory? _selectedCategory;

  Currency _selectedCurrency = Currency(
      code: 'USD',
      name: "United States Dollar",
      symbol: '\$',
      number: 840,
      flag: "USD",
      decimalDigits: 2,
      namePlural: 'US dollars',
      symbolOnLeft: true,
      decimalSeparator: '.',
      thousandsSeparator: ',',
      spaceBetweenAmountAndSymbol: false);

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _expenseNameController.dispose();
    _amountController.dispose();
    _expenseDescriptionController.dispose();
    _placeOfPurchase.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final provider = Provider.of<PropertiesProvider>(context, listen: false);

      // Utworzenie obiektu Expanses
      Expanses expanse = Expanses(
        authorId: loggedUser!.id,
        name: _expenseNameController.text.trim(),
        description: _expenseDescriptionController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        currency: _selectedCurrency.code,
        category: _selectedCategory.toString(),
        placeOfPurchase: _placeOfPurchase.text.trim(),
      );

      provider.addExpense(expanse).then((success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Wydatek "${_expenseNameController.text}" dodany w walucie ${_selectedCurrency.symbol}!',
            ),
          ),
        );
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dodaj nowe wydatki'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _expenseNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nazwa wydatku',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Proszę wpisać nazwę wydatku';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _expenseDescriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Opis wydatku',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: 'Kwota',
                          border: const OutlineInputBorder(),
                          prefixText: _selectedCurrency.symbol,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Proszę wpisać kwotę';
                          }
                          final parsed = double.tryParse(value.trim());
                          if (parsed == null || parsed <= 0) {
                            return 'Proszę wpisać prawidłową kwotę';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        showCurrencyPicker(
                          context: context,
                          showFlag: true,
                          showSearchField: true,
                          onSelect: (Currency currency) {
                            setState(() {
                              _selectedCurrency = currency;
                            });
                          },
                        );
                      },
                      child: Text(
                        _selectedCurrency.symbol,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _placeOfPurchase,
                  decoration: const InputDecoration(
                    labelText: 'Miejsce zakupu',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16.0),
                DropdownButtonFormField<ExpenseCategory>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Kategoria',
                    border: OutlineInputBorder(),
                  ),
                  items: ExpenseCategory.values.map((category) {
                    return DropdownMenuItem<ExpenseCategory>(
                      value: category,
                      child: Text(category.toString().split('.').last),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Proszę wybrać kategorię';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('DODAJ'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
