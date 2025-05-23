import 'package:flutter/material.dart';
// Import the rating star component

/// A reusable popup menu with predefined options
class OptionMenu extends StatelessWidget {
  /// Callback for when an option is selected
  final Function(String) onOptionSelected;

  /// Optional icon to display for the menu button
  final IconData? icon;

  /// Optional tooltip text for the menu button
  final String? tooltip;

  const OptionMenu({
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
              value: 'users',
              child: Row(
                children: [
                  Icon(Icons.people),
                  SizedBox(width: 8),
                  Text('User List'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'publisher',
              child: Row(
                children: [
                  Icon(Icons.person),
                  SizedBox(width: 8),
                  Text('Publisher List'),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'categories',
              child: Row(
                children: [
                  Icon(Icons.category),
                  SizedBox(width: 8),
                  Text('Category List'),
                ],
              ),
            ),

            const PopupMenuItem<String>(
              value: 'evaluations',
              child: Row(
                children: [
                  Icon(Icons.rate_review),
                  SizedBox(width: 8),
                  Text('Reviews'),
                ],
              ),
            ),
          ],
    );
  }
}
