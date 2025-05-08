import 'package:flutter/material.dart';
// Import the rating star component

/// A reusable popup menu with predefined options
class OptionMenuUser extends StatelessWidget {
  /// Callback for when an option is selected
  final Function(String) onOptionSelected;

  /// Optional icon to display for the menu button
  final IconData? icon;

  /// Optional tooltip text for the menu button
  final String? tooltip;

  const OptionMenuUser({
    super.key,
    required this.onOptionSelected,
    this.icon = Icons.more_vert,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(icon),
      tooltip: tooltip,
      onSelected: onOptionSelected,
      itemBuilder:
          (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'books',
              child: Row(
                children: [
                  Icon(Icons.book),
                  SizedBox(width: 8),
                  Text('Book List'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'orders',
              child: Row(
                children: [
                  Icon(Icons.shopping_cart),
                  SizedBox(width: 8),
                  Text('Order List'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'ratings',
              child: Row(
                children: [
                  Icon(Icons.star),
                  SizedBox(width: 8),
                  Text('Rate Book'),
                ],
              ),
            ),
          ],
    );
  }
}
