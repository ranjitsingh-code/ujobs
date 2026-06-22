import 'package:flutter/material.dart';
import 'ujob_dropdown_field.dart';

class UJobDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const UJobDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return UJobDropdownField<String>.simple(
      label: label,
      value: items.contains(value) ? value : null,
      options: items.map((item) => (item, item)).toList(),
      onChanged: onChanged,
    );
  }
}
