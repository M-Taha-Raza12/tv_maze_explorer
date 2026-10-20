import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/html_utils.dart';
import '../../../domain/entities/episode.dart';
import '../../../shared/widgets/rating_badge.dart';
import '../../../shared/widgets/show_poster_image.dart';

/// Card displaying detailed information for an episode.
class EpisodeCard extends StatelessWidget {
  final Episode episode;

  const EpisodeCard({super.key, required this.episode});

  @override
  Widget build(BuildContext context) {
    final cleanSummary = HtmlUtils.stripHtml(episode.summary);
    final airdate = DateFormatter.formatAirDate(episode.airdate);
    final runtime = DateFormatter.formatRuntime(episode.runtime);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Episode Thumbnail
              ShowPosterImage(
                imageUrl: episode.thumbnailUrl,
                width: 100,
                height: 65,
                borderRadius: 8,
                fit: BoxFit.cover,
                fallbackIcon: Icons.tv_rounded,
              ),
              const SizedBox(width: 12),

              // Code, Title, Airdate, Runtime
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            episode.episodeCode,
                            style: const TextStyle(
                              color: AppColors.primaryLight,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (episode.rating != null)
                          RatingBadge(
                            rating: episode.rating,
                            fontSize: 10,
                            iconSize: 12,
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      episode.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$airdate • $runtime',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Synopsis if available
          if (cleanSummary.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              cleanSummary,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
