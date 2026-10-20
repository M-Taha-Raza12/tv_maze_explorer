import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tv_maze_application/data/datasources/watchlist_local_data_source.dart';
import 'package:tv_maze_application/data/models/show_model.dart';
import 'package:tv_maze_application/data/repositories/watchlist_repository_impl.dart';
import 'package:tv_maze_application/domain/entities/show.dart';
import 'package:tv_maze_application/domain/repositories/watchlist_repository.dart';

class MockWatchlistLocalDataSource extends Mock implements WatchlistLocalDataSource {}

class FakeShowModel extends Fake implements ShowModel {}

void main() {
  late MockWatchlistLocalDataSource mockLocalDataSource;
  late WatchlistRepository repository;

  setUpAll(() {
    registerFallbackValue(FakeShowModel());
  });

  setUp(() {
    mockLocalDataSource = MockWatchlistLocalDataSource();
    repository = WatchlistRepositoryImpl(localDataSource: mockLocalDataSource);
  });

  const testShow = Show(
    id: 10,
    name: 'Severance',
  );

  const testShowModel = ShowModel(
    id: 10,
    name: 'Severance',
  );

  group('WatchlistRepositoryImpl', () {
    test('getWatchlist returns typed List<Show>', () async {
      when(() => mockLocalDataSource.getWatchlist())
          .thenAnswer((_) async => [testShowModel]);

      final result = await repository.getWatchlist();

      expect(result.length, 1);
      expect(result.first.id, 10);
      expect(result.first.name, 'Severance');
      verify(() => mockLocalDataSource.getWatchlist()).called(1);
    });

    test('addToWatchlist saves show via local data source', () async {
      when(() => mockLocalDataSource.saveShow(any()))
          .thenAnswer((_) async {});

      await repository.addToWatchlist(testShow);

      verify(() => mockLocalDataSource.saveShow(any())).called(1);
    });

    test('removeFromWatchlist calls local data source with showId', () async {
      when(() => mockLocalDataSource.removeShow(10))
          .thenAnswer((_) async {});

      await repository.removeFromWatchlist(10);

      verify(() => mockLocalDataSource.removeShow(10)).called(1);
    });

    test('isShowInWatchlist queries local data source', () async {
      when(() => mockLocalDataSource.isShowInWatchlist(10))
          .thenAnswer((_) async => true);

      final exists = await repository.isShowInWatchlist(10);

      expect(exists, isTrue);
      verify(() => mockLocalDataSource.isShowInWatchlist(10)).called(1);
    });
  });
}
