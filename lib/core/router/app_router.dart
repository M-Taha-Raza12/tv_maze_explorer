import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../domain/entities/show.dart';
import '../../features/details/screens/show_details_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/watchlist/screens/watchlist_screen.dart';
import '../../features/welcome/screens/welcome_screen.dart';

/// Central GoRouter configuration with StatefulShellRoute for tabs, welcome onboarding, and sub-routes for show details.
class AppRouter {
  AppRouter._();

  /// Default singleton router starting at the front welcoming page.
  static final GoRouter router = createRouter();

  /// Factory to construct a GoRouter instance with configurable initial location.
  static GoRouter createRouter({
    String initialLocation = '/welcome',
    GlobalKey<NavigatorState>? navigatorKey,
  }) {
    final rootKey = navigatorKey ?? GlobalKey<NavigatorState>();

    return GoRouter(
      navigatorKey: rootKey,
      initialLocation: initialLocation,
      routes: [
        // Front Welcoming / Onboarding Route
        GoRoute(
          parentNavigatorKey: rootKey,
          path: '/welcome',
          builder: (context, state) => const WelcomeScreen(),
        ),

        // Bottom Navigation Stateful Shell
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return _ScaffoldWithNavBar(navigationShell: navigationShell);
          },
          branches: [
            // Branch 0: Home / Discover
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const HomeScreen(),
                ),
              ],
            ),

            // Branch 1: Search
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/search',
                  builder: (context, state) => const SearchScreen(),
                ),
              ],
            ),

            // Branch 2: Watchlist
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/watchlist',
                  builder: (context, state) => const WatchlistScreen(),
                ),
              ],
            ),

            // Branch 3: Profile
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: '/profile',
                  builder: (context, state) => const ProfileScreen(),
                ),
              ],
            ),
          ],
        ),

        // Show Details Route
        GoRoute(
          parentNavigatorKey: rootKey,
          path: '/show/:id',
          builder: (context, state) {
            final idStr = state.pathParameters['id'] ?? '0';
            final showId = int.tryParse(idStr) ?? 0;
            final initialShow = state.extra is Show ? state.extra as Show : null;

            return ShowDetailsScreen(
              showId: showId,
              initialShow: initialShow,
            );
          },
        ),
      ],
    );
  }
}

class _ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _ScaffoldWithNavBar({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border, width: 0.8)),
        ),
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore_rounded),
              label: 'Discover',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_rounded),
              activeIcon: Icon(Icons.saved_search_rounded),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_border_rounded),
              activeIcon: Icon(Icons.bookmark_rounded),
              label: 'Watchlist',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
