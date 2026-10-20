import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/tv_rating.dart';

/// Pill badge displaying show rating with a star icon.
class RatingBadge extends StatelessWidget {
  final dynamic rating;
  final double fontSize;
  final double iconSize;
  final EdgeInsetsGeometry padding;

  const RatingBadge({
    super.key,
    required this.rating,
    this.fontSize = 12.0,
    this.iconSize = 14.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
  });

  double? get _numericRating {
    if (rating == null) return null;
    if (rating is TvMazeRating) return (rating as TvMazeRating).average;
    if (rating is num) return (rating as num).toDouble();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final numVal = _numericRating;
    final text = numVal != null ? numVal.toStringAsFixed(1) : 'N/A';

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: numVal != null ? AppColors.ratingStar.withValues(alpha: 0.4) : AppColors.border,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.star_rounded,
            size: iconSize,
            color: numVal != null ? AppColors.ratingStar : AppColors.textMuted,
          ),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
