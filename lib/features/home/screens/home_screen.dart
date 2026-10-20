import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../domain/entities/show.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/rating_badge.dart';
import '../../../shared/widgets/show_card.dart';
import '../../../shared/widgets/show_poster.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

/// Polished TV show discovery screen featuring hero highlights, show grid, and infinite pagination.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isNearBottom) {
      context.read<HomeBloc>().add(const HomeLoadMoreRequested());
    }
  }

  bool get _isNearBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll - 250);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.tv_rounded, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TVMaze Explorer',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Discover Shows & Series',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: BlocConsumer<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state is HomeLoaded && state.loadMoreError != null) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AppColors.surfaceElevated,
                content: Text(
                  state.loadMoreError!,
                  style: const TextStyle(color: Colors.white),
                ),
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: AppColors.primaryLight,
                  onPressed: () {
                    context.read<HomeBloc>().add(const HomeRetryRequested());
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is HomeLoading || state is HomeInitial) {
            return const AppLoadingIndicator(message: 'Discovering TV shows...');
          }

          if (state is HomeError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => context.read<HomeBloc>().add(const HomeRetryRequested()),
            );
          }

          if (state is HomeLoaded) {
            final shows = state.shows;

            if (shows.isEmpty) {
              return const Center(
                child: Text(
                  'No TV shows available at this time.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
            }

            final featuredShow = shows.first;
            final remainingShows = shows.skip(1).toList();

            return RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.surfaceElevated,
              onRefresh: () async {
                context.read<HomeBloc>().add(const HomeShowsRequested());
              },
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // Search Bar Entry Point
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: _buildSearchEntryPoint(context),
                    ),
                  ),

                  // Hero Featured Banner (From live API data)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      child: _buildFeaturedHeroCard(context, featuredShow),
                    ),
                  ),

                  // Section Title
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Popular Shows',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${shows.length} shows',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Grid of Shows
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
                          final show = remainingShows[index];
                          return ShowCard(
                            show: show,
                            onTap: () => context.push('/show/${show.id}', extra: show),
                          );
                        },
                        childCount: remainingShows.length,
                      ),
                    ),
                  ),

                  // Bottom Pagination Status
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: _buildPaginationFooter(state),
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// Search bar trigger that navigates directly to the search tab.
  Widget _buildSearchEntryPoint(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/search'),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          children: [
            Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Search TV shows, actors, or genres...',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textMuted, size: 14),
          ],
        ),
      ),
    );
  }

  /// Hero Highlight card rendered using real show data from the first API response.
  Widget _buildFeaturedHeroCard(BuildContext context, Show show) {
    return InkWell(
      onTap: () => context.push('/show/${show.id}', extra: show),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 210,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ShowPoster(
              imageUrl: show.backdropUrl ?? show.posterUrl,
              borderRadius: 0,
              fit: BoxFit.cover,
            ),
            // Multi-stop gradient overlay for readable text
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                    AppColors.background.withValues(alpha: 0.95),
                  ],
                  stops: const [0.15, 0.45, 1.0],
                ),
              ),
            ),
            // Hero Content
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'FEATURED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    show.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (show.rating != null && show.ratingAverage != null) ...[
                        RatingBadge(rating: show.rating),
                        const SizedBox(width: 8),
                      ],
                      if (show.genres.isNotEmpty)
                        Expanded(
                          child: Text(
                            show.genres.take(3).join(' • '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Pagination bottom indicator displaying loading spinner, retry action, or end of catalogue.
  Widget _buildPaginationFooter(HomeLoaded state) {
    if (state.isLoadingMore) {
      return const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      );
    }

    if (state.loadMoreError != null) {
      return Center(
        child: Column(
          children: [
            Text(
              state.loadMoreError!,
              style: const TextStyle(color: AppColors.error, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => context.read<HomeBloc>().add(const HomeRetryRequested()),
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Retry Loading More'),
            ),
          ],
        ),
      );
    }

    if (state.hasReachedMax) {
      return const Center(
        child: Text(
          "You've reached the end of the show catalogue",
          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
