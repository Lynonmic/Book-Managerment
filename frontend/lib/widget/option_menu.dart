import 'package:flutter/material.dart';
// Import the rating star component

/// A reusable popup menu with predefined options
class OptionMenu extends StatelessWidget {
  /// Callback for when an option is selected
  final Function(String) onOptionSelected;

  /// Optional tooltip text for the menu button
  final String tooltip;

  const OptionMenu({
    super.key,
    required this.onOptionSelected,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: tooltip,
      icon: const Icon(Icons.more_vert),
      onSelected: onOptionSelected,
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<String>(
          value: 'books',
          child: Text('Books'),
        ),
        const PopupMenuItem<String>(
          value: 'users',
          child: Text('Users'),
        ),
        const PopupMenuItem<String>(
          value: 'publisher',
          child: Text('Publisher'),
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
