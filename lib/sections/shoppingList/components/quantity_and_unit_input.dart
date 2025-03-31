import 'package:flutter/material.dart';

class QuantityAndUnitInput extends StatefulWidget {
  final Function(double) onQuantityChanged;
  final Function(String) onUnitChanged;

  const QuantityAndUnitInput({
    super.key,
    required this.onQuantityChanged,
    required this.onUnitChanged,
  });

  @override
  _QuantityAndUnitInputState createState() => _QuantityAndUnitInputState();
}

class _QuantityAndUnitInputState extends State<QuantityAndUnitInput> {
  final TextEditingController _quantityController = TextEditingController();
  String _selectedUnit = 'kg';

  final List<String> _units = ['kg', 'g', 'pcs', 'liters'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // TextField for Quantity
        Expanded(
          flex: 2,
          child: TextField(
            controller: _quantityController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Quantity',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onChanged: (value) {
              final quantity = double.tryParse(value) ?? 0.0;
              widget.onQuantityChanged(quantity);
            },
          ),
        ),
        const SizedBox(width: 10),
        // DropdownButton for Unit Selection
        Expanded(
          flex: 1,
          child: DropdownButtonFormField<String>(
            value: _selectedUnit,
            items: _units
                .map((unit) => DropdownMenuItem(
                      value: unit,
                      child: Text(unit),
                    ))
                .toList(),
            decoration: InputDecoration(
              labelText: 'Unit',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedUnit = value;
                });
                widget.onUnitChanged(value);
              }
            },
          ),
        ),
      ],
    );
  }
}
