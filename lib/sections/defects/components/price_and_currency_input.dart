import 'package:flutter/material.dart';

class PriceAndCurrencyInput extends StatefulWidget {
  final Function(double) onPriceChanged;
  final Function(String) onCurrencyChanged;

  const PriceAndCurrencyInput({
    super.key,
    required this.onPriceChanged,
    required this.onCurrencyChanged,
  });

  @override
  _PriceAndCurrencyInputState createState() => _PriceAndCurrencyInputState();
}

class _PriceAndCurrencyInputState extends State<PriceAndCurrencyInput> {
  final TextEditingController _priceController = TextEditingController();
  String _selectedCurrency = 'USD';

  final List<String> _currencies = ['USD', 'EUR', 'PLN', 'GBP'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // TextField for Price
        Expanded(
          flex: 2,
          child: TextField(
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Price',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onChanged: (value) {
              final price = double.tryParse(value) ?? 0.0;
              widget.onPriceChanged(price);
            },
          ),
        ),
        const SizedBox(width: 10),
        // DropdownButton for Currency Selection
        Expanded(
          flex: 1,
          child: DropdownButtonFormField<String>(
            value: _selectedCurrency,
            items: _currencies
                .map((currency) => DropdownMenuItem(
                      value: currency,
                      child: Text(currency),
                    ))
                .toList(),
            decoration: InputDecoration(
              labelText: 'Currency',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedCurrency = value;
                });
                widget.onCurrencyChanged(value);
              }
            },
          ),
        ),
      ],
    );
  }
}
