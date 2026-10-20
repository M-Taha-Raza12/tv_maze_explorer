import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_empty_state.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/app_loading_indicator.dart';
import '../../../shared/widgets/show_card.dart';
import '../bloc/search_bloc.dart';
import '../bloc/search_event.dart';
import '../bloc/search_state.dart';

/// Screen providing live debounced TV show search with stale-request protection and instant results.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onClear() {
    _controller.clear();
    context.read<SearchBloc>().add(const SearchClearQuery());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Search TV Shows'),
      ),
      body: Column(
        children: [
          // Debounced Search Input Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Search by title (e.g. Breaking Bad, Dark)...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: _onClear,
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {});
                context.read<SearchBloc>().add(SearchQueryChanged(value));
              },
            ),
          ),

          // State-Driven Results Container
          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                if (state is SearchLoading) {
                  return AppLoadingIndicator(
                    message: 'Searching TVMaze for "${state.query}"...',
                  );
                }

                if (state is SearchError) {
                  return AppErrorWidget(
                    message: state.message,
                    onRetry: () => context.read<SearchBloc>().add(const SearchRetry()),
                  );
                }

                if (state is SearchEmpty) {
                  return AppEmptyState(
                    icon: Icons.search_off_rounded,
                    title: 'No Shows Found',
                    description:
                        'We could not find any series matching "${state.query}". Check your spelling or try another keyword.',
                  );
                }

                if (state is SearchResultsLoaded) {
                  final results = state.results;

                  return CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                        sliver: SliverToBoxAdapter(
                          child: Text(
                            '${results.length} results found for "${state.query}"',
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
                              final show = results[index];
                              return ShowCard(
                                show: show,
                                onTap: () => context.push('/show/${show.id}', extra: show),
                              );
                            },
                            childCount: results.length,
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 24),
                      ),
                    ],
                  );
                }

                // Initial Prompt State
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(
                            Icons.movie_filter_rounded,
                            size: 44,
                            color: AppColors.primaryLight,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Find Your Next Favorite Series',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Type a title or keyword above to instantly search the TVMaze catalogue.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
