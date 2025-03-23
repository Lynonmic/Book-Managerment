import 'package:flutter/material.dart';
import 'package:frontend/widget/rating_star.dart';

class ContentSection extends StatelessWidget {
  final String? title;
  final String body;
  final bool showRating;
  final int rating;
  final Function(int)? onRatingChanged;

  const ContentSection({
    Key? key,
    this.title,
    required this.body,
    this.showRating = false,
    this.rating = 4,
    this.onRatingChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                title!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (showRating)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(body, style: TextStyle(color: Colors.grey[700])),
                const SizedBox(height: 8),
                onRatingChanged != null
                    ? InteractiveStarRating(
                      maxRating: 5,
                      color: Colors.amber,
                      onRatingChanged: onRatingChanged!,
                    )
                    : _buildReadOnlyStars(rating),
              ],
            ),
          if (!showRating)
            Text(body, style: TextStyle(color: Colors.grey[700])),
        ],
      ),
    );
  }

  // Build read-only star display when we only need to show rating
  Widget _buildReadOnlyStars(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }
}
