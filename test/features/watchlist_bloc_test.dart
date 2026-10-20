import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tv_maze_application/domain/entities/show.dart';
import 'package:tv_maze_application/domain/repositories/watchlist_repository.dart';
import 'package:tv_maze_application/features/watchlist/bloc/watchlist_bloc.dart';
import 'package:tv_maze_application/features/watchlist/bloc/watchlist_event.dart';
import 'package:tv_maze_application/features/watchlist/bloc/watchlist_state.dart';

class MockWatchlistRepository extends Mock implements WatchlistRepository {}

void main() {
  late MockWatchlistRepository mockWatchlistRepository;
  late WatchlistBloc watchlistBloc;

  setUp(() {
    mockWatchlistRepository = MockWatchlistRepository();
    watchlistBloc = WatchlistBloc(watchlistRepository: mockWatchlistRepository);
  });

  tearDown(() {
    watchlistBloc.close();
  });

  const testShow = Show(id: 1, name: 'Westworld');

  group('WatchlistBloc', () {
    test('initial state is WatchlistInitial', () {
      expect(watchlistBloc.state, const WatchlistInitial());
    });

    blocTest<WatchlistBloc, WatchlistState>(
      'loads saved watchlist shows on LoadWatchlist',
      build: () {
        when(() => mockWatchlistRepository.getWatchlist())
            .thenAnswer((_) async => const [testShow]);
        return watchlistBloc;
      },
      act: (bloc) => bloc.add(const LoadWatchlist()),
      expect: () => [
        const WatchlistLoading(),
        const WatchlistLoaded([testShow]),
      ],
    );

    blocTest<WatchlistBloc, WatchlistState>(
      'emits WatchlistError when loading watchlist fails',
      build: () {
        when(() => mockWatchlistRepository.getWatchlist())
            .thenThrow(Exception('Disk read failure'));
        return watchlistBloc;
      },
      act: (bloc) => bloc.add(const LoadWatchlist()),
      expect: () => [
        const WatchlistLoading(),
        const WatchlistError('Failed to load watchlist: Exception: Disk read failure'),
      ],
    );

    blocTest<WatchlistBloc, WatchlistState>(
      'adds show to watchlist and emits updated list',
      build: () {
        when(() => mockWatchlistRepository.addToWatchlist(testShow))
            .thenAnswer((_) async {});
        when(() => mockWatchlistRepository.getWatchlist())
            .thenAnswer((_) async => const [testShow]);
        return watchlistBloc;
      },
      act: (bloc) => bloc.add(const AddShowToWatchlist(testShow)),
      expect: () => [
        const WatchlistLoaded([testShow]),
      ],
    );

    blocTest<WatchlistBloc, WatchlistState>(
      'removes show from watchlist and emits updated list',
      build: () {
        when(() => mockWatchlistRepository.removeFromWatchlist(1))
            .thenAnswer((_) async {});
        when(() => mockWatchlistRepository.getWatchlist())
            .thenAnswer((_) async => const []);
        return watchlistBloc;
      },
      act: (bloc) => bloc.add(const RemoveShowFromWatchlist(1)),
      expect: () => [
        const WatchlistLoaded([]),
      ],
    );

    blocTest<WatchlistBloc, WatchlistState>(
      'toggles show: removes when already present',
      build: () {
        when(() => mockWatchlistRepository.isShowInWatchlist(1))
            .thenAnswer((_) async => true);
        when(() => mockWatchlistRepository.removeFromWatchlist(1))
            .thenAnswer((_) async {});
        when(() => mockWatchlistRepository.getWatchlist())
            .thenAnswer((_) async => const []);
        return watchlistBloc;
      },
      act: (bloc) => bloc.add(const ToggleWatchlist(testShow)),
      expect: () => [
        const WatchlistLoaded([]),
      ],
    );

    blocTest<WatchlistBloc, WatchlistState>(
      'toggles show: adds when not present',
      build: () {
        when(() => mockWatchlistRepository.isShowInWatchlist(1))
            .thenAnswer((_) async => false);
        when(() => mockWatchlistRepository.addToWatchlist(testShow))
            .thenAnswer((_) async {});
        when(() => mockWatchlistRepository.getWatchlist())
            .thenAnswer((_) async => const [testShow]);
        return watchlistBloc;
      },
      act: (bloc) => bloc.add(const ToggleWatchlist(testShow)),
      expect: () => [
        const WatchlistLoaded([testShow]),
      ],
    );

    test('persistence across BLoC recreation: newly instantiated BLoC restores saved shows', () async {
      when(() => mockWatchlistRepository.getWatchlist())
          .thenAnswer((_) async => const [testShow]);

      // Create first BLoC and load
      final bloc1 = WatchlistBloc(watchlistRepository: mockWatchlistRepository);
      bloc1.add(const LoadWatchlist());
      await expectLater(
        bloc1.stream,
        emitsInOrder([
          const WatchlistLoading(),
          const WatchlistLoaded([testShow]),
        ]),
      );
      await bloc1.close();

      // Create second BLoC simulating app restart
      final bloc2 = WatchlistBloc(watchlistRepository: mockWatchlistRepository);
      bloc2.add(const LoadWatchlist());
      await expectLater(
        bloc2.stream,
        emitsInOrder([
          const WatchlistLoading(),
          const WatchlistLoaded([testShow]),
        ]),
      );
      await bloc2.close();
    });
  });
}
