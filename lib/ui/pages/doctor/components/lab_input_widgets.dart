import 'package:flutter/material.dart';

class LabCategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Widget> children;

  const LabCategoryCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children.map((w) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: w,
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class LabNumberInput extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final String normalRange;
  final Function(String) onValueChange;

  const LabNumberInput({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.normalRange,
    required this.onValueChange,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        suffixText: unit,
        helperText: "Normal: $normalRange",
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      onChanged: onValueChange,
    );
  }
}

class BinaryToggleChip extends StatelessWidget {
  final String label;
  final double selectedValue;
  final String optionFalseLabel;
  final String optionTrueLabel;
  final Function(double) onValueChange;

  const BinaryToggleChip({
    super.key,
    required this.label,
    required this.selectedValue,
    this.optionFalseLabel = "Tidak",
    this.optionTrueLabel = "Ya",
    required this.onValueChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildChip(optionFalseLabel, 0.0),
            const SizedBox(width: 8),
            _buildChip(optionTrueLabel, 1.0),
          ],
        ),
      ],
    );
  }

  Widget _buildChip(String text, double value) {
    final isSelected = selectedValue == value;
    return ChoiceChip(
      label: Text(text),
      selected: isSelected,
      onSelected: (_) => onValueChange(value),
      selectedColor: Colors.blue.withOpacity(0.2),
      checkmarkColor: Colors.blue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.blue : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

class LabDropdownInput extends StatelessWidget {
  final String label;
  final double value;
  final List<MapEntry<double, String>> options;
  final Function(double) onValueChange;

  const LabDropdownInput({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onValueChange,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<double>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: options.map((opt) => DropdownMenuItem(
        value: opt.key,
        child: Text(opt.value),
      )).toList(),
      onChanged: (val) {
        if (val != null) onValueChange(val);
      },
    );
  }
}
