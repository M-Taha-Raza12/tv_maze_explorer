import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../watchlist/bloc/watchlist_bloc.dart';
import '../../watchlist/bloc/watchlist_event.dart';
import '../../watchlist/bloc/watchlist_state.dart';

/// Screen presenting app identity, watchlist stats, clean architecture overview, and cache controls.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile & Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Identity Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryDark.withValues(alpha: 0.6),
                  AppColors.surfaceElevated,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.tv_rounded, size: 36, color: Colors.white),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TVMaze Explorer',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Flutter TV Show Discovery & Watchlist',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Library Statistics
          const Text(
            'Library Statistics',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          BlocBuilder<WatchlistBloc, WatchlistState>(
            builder: (context, state) {
              final count = (state is WatchlistLoaded) ? state.shows.length : 0;

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.bookmark_rounded, color: AppColors.primaryLight, size: 24),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Saved in Watchlist',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Stored locally via SharedPreferences',
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      count.toString(),
                      style: const TextStyle(
                        color: AppColors.primaryLight,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Technical Architecture
          const Text(
            'Technical Architecture',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              children: [
                _TechRow(label: 'Design Architecture', value: 'Feature-First Clean Architecture'),
                Divider(height: 16),
                _TechRow(label: 'State Management', value: 'flutter_bloc & bloc'),
                Divider(height: 16),
                _TechRow(label: 'HTTP Client', value: 'Dio with CancelTokens'),
                Divider(height: 16),
                _TechRow(label: 'Local Persistence', value: 'SharedPreferences JSON storage'),
                Divider(height: 16),
                _TechRow(label: 'Declarative Routing', value: 'go_router (StatefulShellRoute)'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // App Information
          const Text(
            'App Information',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Material(
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              leading: const Icon(Icons.auto_awesome_rounded, color: AppColors.primaryLight),
              title: const Text('Welcome Tour & Highlights', style: TextStyle(color: AppColors.textPrimary)),
              subtitle: const Text('Review the front welcoming onboarding guide'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
              onTap: () => context.push('/welcome'),
            ),
          ),

          const SizedBox(height: 24),

          // Data Management
          const Text(
            'Data Management',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Material(
            color: AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: const BorderSide(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              leading: const Icon(Icons.delete_sweep_rounded, color: AppColors.error),
              title: const Text('Clear Watchlist', style: TextStyle(color: AppColors.error)),
              subtitle: const Text('Remove all saved TV series from local storage'),
              onTap: () => _confirmClearWatchlist(context),
            ),
          ),

          const SizedBox(height: 32),

          // API Attribution
          const Center(
            child: Text(
              'Data provided by the public TVMaze REST API\nhttps://api.tvmaze.com',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _confirmClearWatchlist(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: const Text('Clear Watchlist?'),
        content: const Text('Are you sure you want to remove all saved shows from your watchlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              final watchlistBloc = context.read<WatchlistBloc>();
              final state = watchlistBloc.state;
              if (state is WatchlistLoaded) {
                for (final show in state.shows) {
                  watchlistBloc.add(RemoveShowFromWatchlist(show.id));
                }
              }
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppColors.surfaceElevated,
                  content: Text('Watchlist cleared successfully'),
                ),
              );
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

class _TechRow extends StatelessWidget {
  final String label;
  final String value;

  const _TechRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 13, color: AppColors.primaryLight, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
