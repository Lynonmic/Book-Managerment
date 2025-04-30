import 'package:flutter/material.dart';

class InteractiveStarRating extends StatefulWidget {
  final int maxRating;
  final double initialRating;
  final double size;
  final Color color;
  final Function(double) onRatingChanged;

  const InteractiveStarRating({
    Key? key,
    this.maxRating = 5,
    this.initialRating = 0.0,
    this.size = 24.0,
    this.color = Colors.amber,
    required this.onRatingChanged,
  }) : super(key: key);

  @override
  _InteractiveStarRatingState createState() => _InteractiveStarRatingState();
}

class _InteractiveStarRatingState extends State<InteractiveStarRating> {
  late double _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.maxRating, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _rating = index + 1.0;
              widget.onRatingChanged(_rating);
            });
          },
          child: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            color: widget.color,
            size: widget.size,
          ),
        );
      }),
    );
  }
}

// A simpler non-interactive star display widget
class StarRating extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;
  final Color color;
  final MainAxisAlignment alignment;

  const StarRating({
    Key? key,
    required this.rating,
    this.maxRating = 5,
    this.size = 16.0,
    this.color = Colors.amber,
    this.alignment = MainAxisAlignment.start,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: alignment,
      children: List.generate(maxRating, (index) {
        IconData iconData;
        if (index < rating.floor()) {
          iconData = Icons.star; // Full star
        } else if (index == rating.floor() && rating % 1 > 0) {
          iconData = Icons.star_half; // Half star
        } else {
          iconData = Icons.star_border; // Empty star
        }
        
        return Icon(
          iconData,
          color: color,
          size: size,
        );
      }),
    );
  }
}
