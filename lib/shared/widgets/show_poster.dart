import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Reusable poster widget with caching, placeholder spinner, and graceful fallback.
class ShowPoster extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxFit fit;
  final IconData fallbackIcon;

  const ShowPoster({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.borderRadius = 12.0,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.movie_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final validUrl = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        width: width,
        height: height,
        color: AppColors.surfaceElevated,
        child: validUrl
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                width: width,
                height: height,
                fit: fit,
                placeholder: (context, url) => Container(
                  width: width,
                  height: height,
                  color: AppColors.surfaceElevated,
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => _buildFallback(),
              )
            : _buildFallback(),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      color: AppColors.surfaceElevated,
      child: Center(
        child: Icon(
          fallbackIcon,
          size: (width != null && width! < 60) ? 24 : 36,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}
