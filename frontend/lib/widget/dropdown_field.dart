// lib/widgets/dropdown_field.dart
import 'package:flutter/material.dart';

class DropdownField extends StatefulWidget {
  final String label;
  final String value;
  final List<String> options;
  final Function(String) onChanged;

  const DropdownField({
    Key? key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<DropdownField> createState() => _DropdownFieldState();
}

class _DropdownFieldState extends State<DropdownField> {
  late String selectedValue;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    selectedValue =
        widget.value.isNotEmpty ? widget.value : widget.options.first;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            setState(() {
              isExpanded = !isExpanded;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(selectedValue),
                const Spacer(),
                Icon(isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        if (isExpanded)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children:
                  widget.options.map((option) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedValue = option;
                          isExpanded = false;
                        });
                        widget.onChanged(option);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color:
                              selectedValue == option
                                  ? Colors.purple.withOpacity(0.1)
                                  : Colors.white,
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Text(option),
                      ),
                    );
                  }).toList(),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}
