import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tv_maze_application/core/theme/app_theme.dart';
import 'package:tv_maze_application/features/welcome/screens/welcome_screen.dart';

void main() {
  Widget buildTestableWelcomeWidget({GoRouter? router}) {
    final effectiveRouter = router ??
        GoRouter(
          initialLocation: '/welcome',
          routes: [
            GoRoute(
              path: '/welcome',
              builder: (context, state) => const WelcomeScreen(),
            ),
            GoRoute(
              path: '/',
              builder: (context, state) => const Scaffold(body: Text('Home Destination')),
            ),
          ],
        );

    return MaterialApp.router(
      theme: AppTheme.darkTheme,
      routerConfig: effectiveRouter,
    );
  }

  group('WelcomeScreen Widget Tests', () {
    testWidgets('renders brand title, glowing icon, and all feature highlights', (tester) async {
      await tester.pumpWidget(buildTestableWelcomeWidget());
      await tester.pumpAndSettle();

      // Brand & Heading
      expect(find.text('TVMaze Explorer'), findsWidgets);
      expect(find.byIcon(Icons.live_tv_rounded), findsOneWidget);
      expect(find.textContaining('Welcome to'), findsOneWidget);

      // Feature cards
      expect(find.text('Live Discovery & Ratings'), findsOneWidget);
      expect(find.text('Instant Debounced Search'), findsOneWidget);
      expect(find.text('Seasons & Full Cast'), findsOneWidget);
      expect(find.text('Personal Offline Watchlist'), findsOneWidget);

      // Action buttons
      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Powered by TVMaze Public API • No account required'), findsOneWidget);
    });

    testWidgets('tapping Get Started navigates to home route', (tester) async {
      await tester.pumpWidget(buildTestableWelcomeWidget());
      await tester.pumpAndSettle();

      expect(find.text('Get Started'), findsOneWidget);
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(find.text('Home Destination'), findsOneWidget);
    });

    testWidgets('tapping Skip navigates to home route', (tester) async {
      await tester.pumpWidget(buildTestableWelcomeWidget());
      await tester.pumpAndSettle();

      expect(find.text('Skip'), findsOneWidget);
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      expect(find.text('Home Destination'), findsOneWidget);
    });
  });
}
