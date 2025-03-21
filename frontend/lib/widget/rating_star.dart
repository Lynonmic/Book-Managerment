import 'package:flutter/material.dart';

class RatingStar extends StatelessWidget {
  final int rating;

  const RatingStar({
    Key? key,
    required this.rating,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          size: 16,
          color: Colors.amber,
        );
      }),
    );
  }
}

class InteractiveStarRating extends StatefulWidget {
  final Function(double) onRatingChanged;

  const InteractiveStarRating({
    Key? key,
    required this.onRatingChanged,
  }) : super(key: key);

  @override
  State<InteractiveStarRating> createState() => _InteractiveStarRatingState();
}

class _InteractiveStarRatingState extends State<InteractiveStarRating> {
  double _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _rating = index + 1;
            });
            widget.onRatingChanged(_rating);
          },
          child: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            size: 32,
            color: Colors.amber,
          ),
        );
      }),
    );
  }
}
