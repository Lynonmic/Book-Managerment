import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class BookItemUser extends StatelessWidget {
  final String title;
  final String imageUrl;
  final double price;
  final double rating;
  final String category;
  final VoidCallback? onTap;

  const BookItemUser({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.rating,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book cover image from network
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Icon(Icons.broken_image),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(child: CircularProgressIndicator());
                  },
                ),
              ),

              const SizedBox(height: 8),

              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              // Category
              Text(
                category,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),

              const SizedBox(height: 6),

              // Rating
              Row(
                children: [
                  RatingBarIndicator(
                    rating: rating,
                    itemBuilder:
                        (context, index) =>
                            const Icon(Icons.star, color: Colors.amber),
                    itemCount: 5,
                    itemSize: 14.0,
                    direction: Axis.horizontal,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${rating.toStringAsFixed(1)})',
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // Price
              Text(
                '₫${price.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 99, 20, 202),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
