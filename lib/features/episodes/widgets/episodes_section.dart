import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../bloc/episodes_bloc.dart';
import '../bloc/episodes_event.dart';
import '../bloc/episodes_state.dart';
import 'episode_card.dart';

/// Section in show details rendering season selector and episode cards.
class EpisodesSection extends StatelessWidget {
  final int showId;

  const EpisodesSection({super.key, required this.showId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EpisodesBloc, EpisodesState>(
      builder: (context, state) {
        if (state is EpisodesLoading || state is EpisodesInitial) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
          );
        }

        if (state is EpisodesError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: TextButton.icon(
                onPressed: () => context.read<EpisodesBloc>().add(EpisodesRetryRequested(showId)),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Failed to load episodes. Tap to retry.'),
              ),
            ),
          );
        }

        if (state is EpisodesEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No episodes found for this show.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ),
          );
        }

        if (state is EpisodesLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Season Pills
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Text(
                      'Episodes',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${state.allEpisodes.length} Total',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Season Selector Pills
              if (state.seasons.length > 1)
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: state.seasons.length,
                    itemBuilder: (context, index) {
                      final season = state.seasons[index];
                      final isSelected = season == state.selectedSeason;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text('Season $season'),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              context.read<EpisodesBloc>().add(SeasonSelected(season));
                            }
                          },
                          selectedColor: AppColors.primary,
                          backgroundColor: AppColors.surfaceElevated,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isSelected ? AppColors.primaryLight : AppColors.border,
                            ),
                          ),
                          showCheckmark: false,
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 12),

              // Episode Cards List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.seasonEpisodes.length,
                  itemBuilder: (context, index) {
                    final ep = state.seasonEpisodes[index];
                    return EpisodeCard(episode: ep);
                  },
                ),
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
