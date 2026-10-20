import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/show_card.dart';
import '../bloc/watchlist_bloc.dart';
import '../bloc/watchlist_event.dart';
import '../bloc/watchlist_state.dart';

/// Screen displaying locally saved personal watchlist shows with quick-delete and details routing.
class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: BlocBuilder<WatchlistBloc, WatchlistState>(
          builder: (context, state) {
            final count = (state is WatchlistLoaded) ? state.shows.length : 0;
            return Row(
              children: [
                const Text('My Watchlist'),
                if (count > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      count.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
      body: BlocBuilder<WatchlistBloc, WatchlistState>(
        builder: (context, state) {
          if (state is WatchlistLoading) {
            return const AppLoadingIndicator(message: 'Loading your watchlist...');
          }

          if (state is WatchlistError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => context.read<WatchlistBloc>().add(const LoadWatchlist()),
            );
          }

          if (state is WatchlistLoaded) {
            final shows = state.shows;

            if (shows.isEmpty) {
              return AppEmptyState(
                icon: Icons.bookmark_border_rounded,
                title: 'Your Watchlist is Empty',
                description:
                    'Keep track of movies and series you want to watch. Tap the bookmark icon on any show to save it here.',
                actionLabel: 'Explore Shows',
                onAction: () => context.go('/'),
              );
            }

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      '${shows.length} saved series',
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.62,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 14,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final show = shows[index];
                        return Stack(
                          children: [
                            // Show Card
                            Positioned.fill(
                              child: ShowCard(
                                show: show,
                                onTap: () => context.push('/show/${show.id}', extra: show),
                              ),
                            ),
                            // Quick Remove Button
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.surface.withValues(alpha: 0.85),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: IconButton(
                                  iconSize: 18,
                                  padding: const EdgeInsets.all(6),
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                                  tooltip: 'Remove from Watchlist',
                                  onPressed: () {
                                    context.read<WatchlistBloc>().add(RemoveShowFromWatchlist(show.id));
                                    ScaffoldMessenger.of(context).clearSnackBars();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: AppColors.surfaceElevated,
                                        content: Text('Removed "${show.name}"'),
                                        action: SnackBarAction(
                                          label: 'Undo',
                                          textColor: AppColors.primaryLight,
                                          onPressed: () {
                                            context.read<WatchlistBloc>().add(AddShowToWatchlist(show));
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      childCount: shows.length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 32),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
