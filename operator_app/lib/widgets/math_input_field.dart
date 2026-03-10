import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MathInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? unit; // Например, "м^3" или "Па"

  const MathInputField({
    super.key,
    required this.controller,
    required this.label,
    this.hint = 'Введите значение',
    this.icon = Icons.edit,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          TextInputFormatter.withFunction((oldValue, newValue) {
            return newValue.copyWith(
              text: newValue.text.replaceAll(',', '.'),
            );
          }),
        ],
        style: const TextStyle(color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          suffixText: unit, // Единицы измерения в конце поля
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }
}