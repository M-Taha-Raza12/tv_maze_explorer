import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tv_maze_application/core/network/api_exceptions.dart';
import 'package:tv_maze_application/domain/entities/episode.dart';
import 'package:tv_maze_application/domain/repositories/show_repository.dart';
import 'package:tv_maze_application/features/episodes/bloc/episodes_bloc.dart';
import 'package:tv_maze_application/features/episodes/bloc/episodes_event.dart';
import 'package:tv_maze_application/features/episodes/bloc/episodes_state.dart';

class MockShowRepository extends Mock implements ShowRepository {}

void main() {
  late MockShowRepository mockShowRepository;
  late EpisodesBloc episodesBloc;

  setUp(() {
    mockShowRepository = MockShowRepository();
    episodesBloc = EpisodesBloc(showRepository: mockShowRepository);
  });

  tearDown(() {
    episodesBloc.close();
  });

  const ep1 = Episode(id: 1, name: 'Pilot', season: 1, number: 1);
  const ep2 = Episode(id: 2, name: 'The Fire', season: 1, number: 2);
  const ep3 = Episode(id: 3, name: 'Heads Will Roll', season: 2, number: 1);

  group('EpisodesBloc', () {
    test('initial state is EpisodesInitial', () {
      expect(episodesBloc.state, const EpisodesInitial());
    });

    blocTest<EpisodesBloc, EpisodesState>(
      'groups episodes by season and sets initial selected season',
      build: () {
        when(() => mockShowRepository.getShowEpisodes(1))
            .thenAnswer((_) async => const [ep1, ep2, ep3]);
        return episodesBloc;
      },
      act: (bloc) => bloc.add(const EpisodesRequested(1)),
      expect: () => [
        const EpisodesLoading(),
        const EpisodesLoaded(
          allEpisodes: [ep1, ep2, ep3],
          seasons: [1, 2],
          selectedSeason: 1,
          seasonEpisodes: [ep1, ep2],
        ),
      ],
    );

    blocTest<EpisodesBloc, EpisodesState>(
      'switches selected season and filters season episodes on SeasonSelected',
      build: () => episodesBloc,
      seed: () => const EpisodesLoaded(
        allEpisodes: [ep1, ep2, ep3],
        seasons: [1, 2],
        selectedSeason: 1,
        seasonEpisodes: [ep1, ep2],
      ),
      act: (bloc) => bloc.add(const SeasonSelected(2)),
      expect: () => [
        const EpisodesLoaded(
          allEpisodes: [ep1, ep2, ep3],
          seasons: [1, 2],
          selectedSeason: 2,
          seasonEpisodes: [ep3],
        ),
      ],
    );

    blocTest<EpisodesBloc, EpisodesState>(
      'emits EpisodesEmpty when show has no episodes',
      build: () {
        when(() => mockShowRepository.getShowEpisodes(99))
            .thenAnswer((_) async => []);
        return episodesBloc;
      },
      act: (bloc) => bloc.add(const EpisodesRequested(99)),
      expect: () => [
        const EpisodesLoading(),
        const EpisodesEmpty(),
      ],
    );

    blocTest<EpisodesBloc, EpisodesState>(
      'emits EpisodesError when fetching episodes fails',
      build: () {
        when(() => mockShowRepository.getShowEpisodes(1))
            .thenThrow(const NetworkException('Network timeout'));
        return episodesBloc;
      },
      act: (bloc) => bloc.add(const EpisodesRequested(1)),
      expect: () => [
        const EpisodesLoading(),
        const EpisodesError('Network timeout'),
      ],
    );

    blocTest<EpisodesBloc, EpisodesState>(
      'retries fetching episodes on EpisodesRetryRequested',
      build: () {
        when(() => mockShowRepository.getShowEpisodes(1))
            .thenAnswer((_) async => const [ep1]);
        return episodesBloc;
      },
      seed: () => const EpisodesError('Timeout'),
      act: (bloc) => bloc.add(const EpisodesRetryRequested(1)),
      expect: () => [
        const EpisodesLoading(),
        const EpisodesLoaded(
          allEpisodes: [ep1],
          seasons: [1],
          selectedSeason: 1,
          seasonEpisodes: [ep1],
        ),
      ],
    );
  });
}
