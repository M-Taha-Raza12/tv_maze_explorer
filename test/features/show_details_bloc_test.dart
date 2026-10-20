import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tv_maze_application/core/network/api_exceptions.dart';
import 'package:tv_maze_application/domain/entities/show.dart';
import 'package:tv_maze_application/domain/repositories/show_repository.dart';
import 'package:tv_maze_application/features/details/bloc/show_details_bloc.dart';
import 'package:tv_maze_application/features/details/bloc/show_details_event.dart';
import 'package:tv_maze_application/features/details/bloc/show_details_state.dart';

class MockShowRepository extends Mock implements ShowRepository {}

void main() {
  late MockShowRepository mockShowRepository;
  late ShowDetailsBloc detailsBloc;

  setUp(() {
    mockShowRepository = MockShowRepository();
    detailsBloc = ShowDetailsBloc(showRepository: mockShowRepository);
  });

  tearDown(() {
    detailsBloc.close();
  });

  const testShow = Show(
    id: 1,
    name: 'Under the Dome',
    premiered: '2013-06-24',
    ended: '2015-09-10',
    summary: 'A small town is suddenly sealed off.',
  );

  group('ShowDetailsBloc', () {
    test('initial state is ShowDetailsInitial', () {
      expect(detailsBloc.state, const ShowDetailsInitial());
    });

    blocTest<ShowDetailsBloc, ShowDetailsState>(
      'emits [ShowDetailsLoading, ShowDetailsLoaded] on successful fetch',
      build: () {
        when(() => mockShowRepository.getShowDetails(1))
            .thenAnswer((_) async => testShow);
        return detailsBloc;
      },
      act: (bloc) => bloc.add(const ShowDetailsRequested(1)),
      expect: () => [
        const ShowDetailsLoading(),
        const ShowDetailsLoaded(testShow),
      ],
      verify: (_) {
        verify(() => mockShowRepository.getShowDetails(1)).called(1);
      },
    );

    blocTest<ShowDetailsBloc, ShowDetailsState>(
      'emits [ShowDetailsLoading, ShowDetailsError] when API request fails',
      build: () {
        when(() => mockShowRepository.getShowDetails(1))
            .thenThrow(const NotFoundException('Show not found'));
        return detailsBloc;
      },
      act: (bloc) => bloc.add(const ShowDetailsRequested(1)),
      expect: () => [
        const ShowDetailsLoading(),
        const ShowDetailsError('Show not found'),
      ],
    );

    blocTest<ShowDetailsBloc, ShowDetailsState>(
      'retries fetching details on ShowDetailsRetryRequested',
      build: () {
        when(() => mockShowRepository.getShowDetails(1))
            .thenAnswer((_) async => testShow);
        return detailsBloc;
      },
      seed: () => const ShowDetailsError('Failed to load'),
      act: (bloc) => bloc.add(const ShowDetailsRetryRequested(1)),
      expect: () => [
        const ShowDetailsLoading(),
        const ShowDetailsLoaded(testShow),
      ],
    );
  });
}
