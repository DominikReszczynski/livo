import 'package:flutter/material.dart';

class CategoryAndPriorityInput extends StatefulWidget {
  final Function(String) onCategoryChanged;
  final Function(String) onPriorityChanged;

  const CategoryAndPriorityInput({
    super.key,
    required this.onCategoryChanged,
    required this.onPriorityChanged,
  });

  @override
  _CategoryAndPriorityInputState createState() =>
      _CategoryAndPriorityInputState();
}

class _CategoryAndPriorityInputState extends State<CategoryAndPriorityInput> {
  String _selectedCategory = 'Groceries';
  String _selectedPriority = 'Low';

  final List<String> _categories = [
    'Groceries',
    'Electronics',
    'Clothing',
    'Furniture',
    'Miscellaneous'
  ];

  final List<String> _priorities = ['Low', 'Medium', 'High'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // DropdownButton for Category
        DropdownButtonFormField<String>(
          value: _selectedCategory,
          items: _categories
              .map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  ))
              .toList(),
          decoration: InputDecoration(
            labelText: 'Category',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedCategory = value;
              });
              widget.onCategoryChanged(value);
            }
          },
        ),
        const SizedBox(height: 10),
        // DropdownButton for Priority
        DropdownButtonFormField<String>(
          value: _selectedPriority,
          items: _priorities
              .map((priority) => DropdownMenuItem(
                    value: priority,
                    child: Text(priority),
                  ))
              .toList(),
          decoration: InputDecoration(
            labelText: 'Priority',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedPriority = value;
              });
              widget.onPriorityChanged(value);
            }
          },
        ),
      ],
    );
  }
}
