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
              value: 'authors',
              child: Row(
                children: [
                  Icon(Icons.person),
                  SizedBox(width: 8),
                  Text('Author List'),
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

// Example usage:
// OptionMenu(
//   onOptionSelected: (value) {
//     switch (value) {
//       case 'books':
//         // Navigate to book list
//         break;
//       case 'users':
//         // Navigate to user list
//         break;
//       case 'authors':
//         // Navigate to author list
//         break;
//       case 'ratings':
//         // Show rating dialog
//         showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: Text('Rate this book'),
//             content: InteractiveStarRating(
//               onRatingChanged: (rating) {
//                 // Handle rating change
//               },
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: Text('OK'),
//               ),
//             ],
//           ),
//         );
//         break;
//     }
//   },
// )
