import 'package:flutter/material.dart';

class InteractiveStarRating extends StatefulWidget {
  final int maxRating;
  final Color color;
  final double size;
  final Function(int rating) onRatingChanged;

  const InteractiveStarRating({
    super.key,
    this.maxRating = 5,
    this.color = Colors.black,
    this.size = 30,
    required this.onRatingChanged,
  });

  @override
  _InteractiveStarRatingState createState() => _InteractiveStarRatingState();
}

class _InteractiveStarRatingState extends State<InteractiveStarRating> {
  int _currentRating = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.maxRating, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _currentRating = index + 1;
            });
            widget.onRatingChanged(_currentRating);
          },
          child: Icon(
            index < _currentRating ? Icons.star : Icons.star_border,
            color: widget.color,
            size: widget.size,
          ),
        );
      }),
    );
  }
}
