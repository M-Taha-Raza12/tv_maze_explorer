import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tv_maze_application/app.dart';
import 'package:tv_maze_application/domain/entities/show.dart';
import 'package:tv_maze_application/domain/repositories/show_repository.dart';
import 'package:tv_maze_application/domain/repositories/watchlist_repository.dart';

class MockShowRepository extends Mock implements ShowRepository {}
class MockWatchlistRepository extends Mock implements WatchlistRepository {}

void main() {
  testWidgets('TvMazeApp full integration smoke test navigates tabs and maintains state', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final mockShowRepo = MockShowRepository();
    final mockWatchlistRepo = MockWatchlistRepository();

    const sampleShow = Show(id: 1, name: 'Under the Dome');
    when(() => mockShowRepo.getShows(page: 0)).thenAnswer((_) async => [sampleShow]);
    when(() => mockWatchlistRepo.getWatchlist()).thenAnswer((_) async => []);

    await tester.pumpWidget(
      TvMazeApp(
        showRepository: mockShowRepo,
        watchlistRepository: mockWatchlistRepo,
      ),
    );
    await tester.pumpAndSettle();

    // Verify Front Welcoming Page
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Live Discovery & Ratings'), findsOneWidget);
    expect(find.text('Instant Debounced Search'), findsOneWidget);

    // Tap Get Started to enter main app shell
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // Verify Discover shows heading
    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('Popular Shows'), findsOneWidget);
    expect(find.text('Under the Dome'), findsOneWidget);

    // Navigate to Search tab
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    expect(find.text('Search TV Shows'), findsOneWidget);
    expect(find.text('Find Your Next Favorite Series'), findsOneWidget);

    // Navigate to Watchlist tab
    await tester.tap(find.text('Watchlist'));
    await tester.pumpAndSettle();
    expect(find.text('My Watchlist'), findsOneWidget);
    expect(find.text('Your Watchlist is Empty'), findsOneWidget);

    // Navigate to Profile tab
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Profile & Settings'), findsOneWidget);
    expect(find.text('Library Statistics'), findsOneWidget);
  });
}
