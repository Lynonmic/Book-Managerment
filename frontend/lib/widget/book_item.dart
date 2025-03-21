import 'package:flutter/material.dart';
import 'package:frontend/widget/rating_star.dart'; // Ensure this path is correct

// If RatingStar is not defined, define it here or import the correct file
class RatingStar extends StatelessWidget {
  final int rating;

  const RatingStar({Key? key, required this.rating}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
        );
      }),
    );
  }
}

class BookItem extends StatelessWidget {
  final String title;
  final String description;
  final int rating;
  final VoidCallback onTap;

  const BookItem({
    Key? key,
    required this.title,
    required this.description,
    required this.rating,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  RatingStar(rating: rating),
                  const SizedBox(width: 8),
                  Text(
                    '($rating)',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
