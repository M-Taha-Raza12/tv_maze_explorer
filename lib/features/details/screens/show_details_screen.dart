import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/html_utils.dart';
import '../../../domain/entities/show.dart';
import '../../../domain/repositories/show_repository.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/genre_chip.dart';
import '../../../shared/widgets/rating_badge.dart';
import '../../../shared/widgets/show_poster.dart';
import '../../cast/bloc/cast_bloc.dart';
import '../../cast/bloc/cast_event.dart';
import '../../cast/widgets/cast_section.dart';
import '../../episodes/bloc/episodes_bloc.dart';
import '../../episodes/bloc/episodes_event.dart';
import '../../episodes/widgets/episodes_section.dart';
import '../../watchlist/bloc/watchlist_bloc.dart';
import '../../watchlist/bloc/watchlist_event.dart';
import '../../watchlist/bloc/watchlist_state.dart';
import '../bloc/show_details_bloc.dart';
import '../bloc/show_details_event.dart';
import '../bloc/show_details_state.dart';

/// Screen displaying complete TV show details, overview, cast, episodes, and watchlist control.
class ShowDetailsScreen extends StatelessWidget {
  final int showId;
  final Show? initialShow;

  const ShowDetailsScreen({
    super.key,
    required this.showId,
    this.initialShow,
  });

  @override
  Widget build(BuildContext context) {
    final showRepo = context.read<ShowRepository>();

    return MultiBlocProvider(
      providers: [
        BlocProvider<ShowDetailsBloc>(
          create: (_) => ShowDetailsBloc(showRepository: showRepo)
            ..add(ShowDetailsRequested(showId)),
        ),
        BlocProvider<CastBloc>(
          create: (_) => CastBloc(showRepository: showRepo)
            ..add(CastRequested(showId)),
        ),
        BlocProvider<EpisodesBloc>(
          create: (_) => EpisodesBloc(showRepository: showRepo)
            ..add(EpisodesRequested(showId)),
        ),
      ],
      child: _ShowDetailsView(showId: showId, initialShow: initialShow),
    );
  }
}

class _ShowDetailsView extends StatefulWidget {
  final int showId;
  final Show? initialShow;

  const _ShowDetailsView({
    required this.showId,
    this.initialShow,
  });

  @override
  State<_ShowDetailsView> createState() => _ShowDetailsViewState();
}

class _ShowDetailsViewState extends State<_ShowDetailsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isSynopsisExpanded = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<ShowDetailsBloc, ShowDetailsState>(
        builder: (context, state) {
          if (state is ShowDetailsLoading && widget.initialShow == null) {
            return const Scaffold(
              body: AppLoadingIndicator(message: 'Loading show details...'),
            );
          }

          if (state is ShowDetailsError && widget.initialShow == null) {
            return Scaffold(
              appBar: AppBar(),
              body: AppErrorWidget(
                message: state.message,
                onRetry: () => context
                    .read<ShowDetailsBloc>()
                    .add(ShowDetailsRetryRequested(widget.showId)),
              ),
            );
          }

          final show = (state is ShowDetailsLoaded)
              ? state.show
              : widget.initialShow!;

          return _buildShowContent(context, show);
        },
      ),
    );
  }

  Widget _buildShowContent(BuildContext context, Show show) {
    final cleanSummary = HtmlUtils.stripHtml(show.summary);
    final premieredYear = DateFormatter.extractYear(show.premiered);
    final endedYear = show.ended != null ? DateFormatter.extractYear(show.ended) : '';
    final yearsSpan = endedYear.isNotEmpty && endedYear != 'N/A' && endedYear != premieredYear
        ? '$premieredYear – $endedYear'
        : premieredYear;
    final runtime = DateFormatter.formatRuntime(show.runtime);
    final network = show.channelOrNetwork ?? 'Online / Syndicated';

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          // Collapsible Backdrop App Bar
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.75),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
            actions: [
              // Watchlist Bookmark Button directly synced with WatchlistBloc
              BlocBuilder<WatchlistBloc, WatchlistState>(
                builder: (context, watchlistState) {
                  final isBookmarked = (watchlistState is WatchlistLoaded) &&
                      watchlistState.containsShow(show.id);

                  return Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surface.withValues(alpha: 0.75),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: isBookmarked ? AppColors.primaryLight : Colors.white,
                      ),
                      tooltip: isBookmarked ? 'Remove from Watchlist' : 'Add to Watchlist',
                      onPressed: () {
                        context.read<WatchlistBloc>().add(ToggleWatchlist(show));
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.surfaceElevated,
                            content: Text(
                              isBookmarked
                                  ? 'Removed "${show.name}" from Watchlist'
                                  : 'Saved "${show.name}" to Watchlist',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  ShowPoster(
                    imageUrl: show.backdropUrl ?? show.posterUrl,
                    borderRadius: 0,
                    fit: BoxFit.cover,
                  ),
                  // Dark gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                          AppColors.background.withValues(alpha: 0.8),
                          AppColors.background,
                        ],
                        stops: const [0.0, 0.35, 0.8, 1.0],
                      ),
                    ),
                  ),
                  // Title, rating badge, year, runtime, and status
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          show.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (show.rating != null && show.ratingAverage != null) ...[
                              RatingBadge(rating: show.rating),
                              const SizedBox(width: 10),
                            ],
                            Text(
                              yearsSpan,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('•', style: TextStyle(color: AppColors.textMuted)),
                            const SizedBox(width: 8),
                            Text(
                              runtime,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (show.status != null) ...[
                              const SizedBox(width: 8),
                              const Text('•', style: TextStyle(color: AppColors.textMuted)),
                              const SizedBox(width: 8),
                              Text(
                                show.status!,
                                style: TextStyle(
                                  color: show.status?.toLowerCase() == 'ended'
                                      ? AppColors.textMuted
                                      : AppColors.success,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tabs Bar: Overview, Cast, Episodes
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.textMuted,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                tabs: const [
                  Tab(text: 'Overview'),
                  Tab(text: 'Cast'),
                  Tab(text: 'Episodes'),
                ],
              ),
            ),
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Overview
          _buildOverviewTab(show, cleanSummary, network),

          // Tab 2: Cast
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: CastSection(showId: show.id),
          ),

          // Tab 3: Episodes
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: EpisodesSection(showId: show.id),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab(Show show, String cleanSummary, String network) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Network & Genres
          Row(
            children: [
              const Icon(Icons.tv_rounded, size: 16, color: AppColors.primaryLight),
              const SizedBox(width: 6),
              Text(
                network,
                style: const TextStyle(
                  color: AppColors.primaryLight,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (show.language != null) ...[
                const SizedBox(width: 8),
                const Text('•', style: TextStyle(color: AppColors.textMuted)),
                const SizedBox(width: 8),
                Text(
                  show.language!,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ],
            ],
          ),

          if (show.genres.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: show.genres.map((g) => GenreChip(label: g)).toList(),
            ),
          ],

          const SizedBox(height: 20),

          // Readable Synopsis
          if (cleanSummary.isNotEmpty) ...[
            const Text(
              'Synopsis',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              cleanSummary,
              maxLines: _isSynopsisExpanded ? null : 5,
              overflow: _isSynopsisExpanded ? null : TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            if (cleanSummary.length > 250)
              InkWell(
                onTap: () {
                  setState(() {
                    _isSynopsisExpanded = !_isSynopsisExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    _isSynopsisExpanded ? 'Show less' : 'Read more',
                    style: const TextStyle(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 20),
          ],

          // Key Metadata Table
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _buildMetaRow('Premiered', DateFormatter.formatAirDate(show.premiered)),
                if (show.ended != null) ...[
                  const Divider(height: 16),
                  _buildMetaRow('Ended', DateFormatter.formatAirDate(show.ended)),
                ],
                const Divider(height: 16),
                _buildMetaRow('Status', show.status ?? 'Unknown'),
                if (show.type != null) ...[
                  const Divider(height: 16),
                  _buildMetaRow('Type', show.type!),
                ],
                if (show.officialSite != null) ...[
                  const Divider(height: 16),
                  _buildMetaRow('Official Site', show.officialSite!),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500),
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.surface,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
