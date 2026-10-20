import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tv_maze_application/core/network/api_exceptions.dart';
import 'package:tv_maze_application/data/datasources/tv_maze_remote_data_source.dart';
import 'package:tv_maze_application/data/models/cast_model.dart';
import 'package:tv_maze_application/data/models/episode_model.dart';
import 'package:tv_maze_application/data/models/show_model.dart';
import 'package:tv_maze_application/data/repositories/show_repository_impl.dart';
import 'package:tv_maze_application/domain/repositories/show_repository.dart';

class MockTvMazeRemoteDataSource extends Mock implements TvMazeRemoteDataSource {}

void main() {
  late MockTvMazeRemoteDataSource mockRemoteDataSource;
  late ShowRepository repository;

  setUp(() {
    mockRemoteDataSource = MockTvMazeRemoteDataSource();
    repository = ShowRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  const sampleShowModel = ShowModel(
    id: 1,
    name: 'Under the Dome',
    premiered: '2013-06-24',
    ended: '2015-09-10',
    genres: ['Drama', 'Sci-Fi'],
  );

  const sampleCastModel = CastModel(
    personId: 10,
    personName: 'Mike Vogel',
    characterId: 20,
    characterName: 'Dale Barbara',
  );

  const sampleEpisodeModel = EpisodeModel(
    id: 101,
    name: 'Pilot',
    season: 1,
    number: 1,
  );

  group('ShowRepositoryImpl', () {
    test('getShows returns typed List<Show> on success', () async {
      when(() => mockRemoteDataSource.getShows(page: 0))
          .thenAnswer((_) async => [sampleShowModel]);

      final result = await repository.getShows(page: 0);

      expect(result.length, 1);
      expect(result.first.id, 1);
      expect(result.first.name, 'Under the Dome');
      verify(() => mockRemoteDataSource.getShows(page: 0)).called(1);
    });

    test('getShows exposes NetworkException and does NOT catch and return empty list', () async {
      when(() => mockRemoteDataSource.getShows(page: 0))
          .thenThrow(const NetworkException('No connection'));

      expect(
        () => repository.getShows(page: 0),
        throwsA(isA<NetworkException>()),
      );
    });

    test('searchShows returns typed List<Show> matching search query', () async {
      when(() => mockRemoteDataSource.searchShows('Dome', cancelToken: any(named: 'cancelToken')))
          .thenAnswer((_) async => [sampleShowModel]);

      final result = await repository.searchShows('Dome');

      expect(result.length, 1);
      expect(result.first.name, 'Under the Dome');
      verify(() => mockRemoteDataSource.searchShows('Dome', cancelToken: any(named: 'cancelToken'))).called(1);
    });

    test('searchShows exposes ServerException when search fails', () async {
      when(() => mockRemoteDataSource.searchShows('Dome', cancelToken: any(named: 'cancelToken')))
          .thenThrow(const ServerException('Server 500'));

      expect(
        () => repository.searchShows('Dome'),
        throwsA(isA<ServerException>()),
      );
    });

    test('getShowDetails returns typed Show entity', () async {
      when(() => mockRemoteDataSource.getShowDetails(1))
          .thenAnswer((_) async => sampleShowModel);

      final result = await repository.getShowDetails(1);

      expect(result.id, 1);
      expect(result.name, 'Under the Dome');
      expect(result.ended, '2015-09-10');
      verify(() => mockRemoteDataSource.getShowDetails(1)).called(1);
    });

    test('getShowDetails exposes NotFoundException on 404', () async {
      when(() => mockRemoteDataSource.getShowDetails(9999))
          .thenThrow(const NotFoundException('Not found'));

      expect(
        () => repository.getShowDetails(9999),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('getShowCast returns typed List<CastMember>', () async {
      when(() => mockRemoteDataSource.getShowCast(1))
          .thenAnswer((_) async => [sampleCastModel]);

      final result = await repository.getShowCast(1);

      expect(result.length, 1);
      expect(result.first.personName, 'Mike Vogel');
      expect(result.first.characterName, 'Dale Barbara');
      verify(() => mockRemoteDataSource.getShowCast(1)).called(1);
    });

    test('getShowCast exposes error when request fails', () async {
      when(() => mockRemoteDataSource.getShowCast(1))
          .thenThrow(const ApiException('Failed to load cast'));

      expect(
        () => repository.getShowCast(1),
        throwsA(isA<ApiException>()),
      );
    });

    test('getShowEpisodes returns typed List<Episode>', () async {
      when(() => mockRemoteDataSource.getShowEpisodes(1))
          .thenAnswer((_) async => [sampleEpisodeModel]);

      final result = await repository.getShowEpisodes(1);

      expect(result.length, 1);
      expect(result.first.name, 'Pilot');
      expect(result.first.episodeCode, 'S01E01');
      verify(() => mockRemoteDataSource.getShowEpisodes(1)).called(1);
    });

    test('getShowEpisodes exposes error when request fails', () async {
      when(() => mockRemoteDataSource.getShowEpisodes(1))
          .thenThrow(const ApiException('Failed to load episodes'));

      expect(
        () => repository.getShowEpisodes(1),
        throwsA(isA<ApiException>()),
      );
    });
  });
}
