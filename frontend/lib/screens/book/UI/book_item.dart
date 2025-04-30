import 'package:flutter/material.dart';

class BookItem extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onTap;
  final Widget? trailing;

  const BookItem({
    super.key,
    required this.title,
    required this.description,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Container(
                    width: 40,
                    height: 40,
                    color: Colors.grey.shade300,
                    child: Icon(Icons.image, color: Colors.grey),
                  ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                 
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Example usage:
// BookItem(
//   title: "Book Title",
//   description: "Book description here",
//   rating: 4,
//   onTap: () {
//     // Handle tap
//   },
// )
