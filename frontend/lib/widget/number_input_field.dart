// lib/widgets/number_input_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberInputField extends StatelessWidget {
  final String label;
  final double? value;
  final Function(double?) onChanged;
  final bool isDecimal;
  final double? min;
  final double? max;
  final String? prefix;
  final String? suffix;
  final bool isRequired;

  const NumberInputField({
    Key? key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.isDecimal = false,
    this.min,
    this.max,
    this.prefix,
    this.suffix,
    this.isRequired = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value?.toString() ?? '',
          keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
          inputFormatters: [
            isDecimal
                ? FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
                : FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: (val) {
            if (val.isEmpty) {
              onChanged(null);
              return;
            }

            final parsedValue =
                isDecimal ? double.tryParse(val) : double.tryParse(val);

            if (parsedValue != null) {
              double? finalValue = parsedValue;
              if (min != null && parsedValue < min!) {
                finalValue = min;
              } else if (max != null && parsedValue > max!) {
                finalValue = max;
              }
              onChanged(finalValue);
            }
          },
          decoration: InputDecoration(
            hintText: 'Value',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
            prefixText: prefix,
            suffixText: suffix,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
