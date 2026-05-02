import 'package:flutter/material.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final int starCount;
  final double size;

  const StarRating({
    super.key,
    required this.rating,
    this.starCount = 5,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(starCount, (index) {
        final starValue = index + 1;
        final isFullStar = rating >= starValue;
        final isHalfStar = rating >= starValue - 0.5 && rating < starValue;
        
        return Icon(
          isFullStar ? Icons.star :
          isHalfStar ? Icons.star_half :
          Icons.star_border,
          color: Colors.amber,
          size: size,
        );
      }),
    );
  }
}