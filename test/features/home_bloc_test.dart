import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tv_maze_application/core/network/api_exceptions.dart';
import 'package:tv_maze_application/domain/entities/show.dart';
import 'package:tv_maze_application/domain/repositories/show_repository.dart';
import 'package:tv_maze_application/features/home/bloc/home_bloc.dart';
import 'package:tv_maze_application/features/home/bloc/home_event.dart';
import 'package:tv_maze_application/features/home/bloc/home_state.dart';

class MockShowRepository extends Mock implements ShowRepository {}

void main() {
  late MockShowRepository mockShowRepository;
  late HomeBloc homeBloc;

  setUp(() {
    mockShowRepository = MockShowRepository();
    homeBloc = HomeBloc(showRepository: mockShowRepository);
  });

  tearDown(() {
    homeBloc.close();
  });

  const page0Shows = [
    Show(id: 1, name: 'Under the Dome'),
    Show(id: 2, name: 'Person of Interest'),
  ];

  const page1Shows = [
    Show(id: 3, name: 'Bitten'),
    Show(id: 4, name: 'Arrow'),
  ];

  group('HomeBloc', () {
    test('initial state is HomeInitial', () {
      expect(homeBloc.state, const HomeInitial());
    });

    blocTest<HomeBloc, HomeState>(
      'emits [HomeLoading, HomeLoaded] on successful initial fetch',
      build: () {
        when(() => mockShowRepository.getShows(page: 0))
            .thenAnswer((_) async => page0Shows);
        return homeBloc;
      },
      act: (bloc) => bloc.add(const HomeShowsRequested()),
      expect: () => [
        const HomeLoading(),
        const HomeLoaded(
          shows: page0Shows,
          currentPage: 0,
          hasReachedMax: false,
        ),
      ],
      verify: (_) {
        verify(() => mockShowRepository.getShows(page: 0)).called(1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'emits [HomeLoading, HomeError] when initial fetch throws ApiException',
      build: () {
        when(() => mockShowRepository.getShows(page: 0))
            .thenThrow(const NetworkException('No internet connection'));
        return homeBloc;
      },
      act: (bloc) => bloc.add(const HomeShowsRequested()),
      expect: () => [
        const HomeLoading(),
        const HomeError('No internet connection'),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'requests next page and appends returned shows on HomeLoadMoreRequested',
      build: () {
        when(() => mockShowRepository.getShows(page: 1))
            .thenAnswer((_) async => page1Shows);
        return homeBloc;
      },
      seed: () => const HomeLoaded(
        shows: page0Shows,
        currentPage: 0,
        hasReachedMax: false,
      ),
      act: (bloc) => bloc.add(const HomeLoadMoreRequested()),
      expect: () => [
        const HomeLoaded(
          shows: page0Shows,
          currentPage: 0,
          hasReachedMax: false,
          isLoadingMore: true,
        ),
        const HomeLoaded(
          shows: [...page0Shows, ...page1Shows],
          currentPage: 1,
          hasReachedMax: false,
          isLoadingMore: false,
        ),
      ],
      verify: (_) {
        verify(() => mockShowRepository.getShows(page: 1)).called(1);
      },
    );

    blocTest<HomeBloc, HomeState>(
      'prevents duplicate load-more requests when already loading',
      build: () => homeBloc,
      seed: () => const HomeLoaded(
        shows: page0Shows,
        currentPage: 0,
        isLoadingMore: true,
      ),
      act: (bloc) => bloc.add(const HomeLoadMoreRequested()),
      expect: () => [],
      verify: (_) {
        verifyNever(() => mockShowRepository.getShows(page: any(named: 'page')));
      },
    );

    blocTest<HomeBloc, HomeState>(
      'stops pagination and sets hasReachedMax when next page is empty',
      build: () {
        when(() => mockShowRepository.getShows(page: 1))
            .thenAnswer((_) async => []);
        return homeBloc;
      },
      seed: () => const HomeLoaded(
        shows: page0Shows,
        currentPage: 0,
        hasReachedMax: false,
      ),
      act: (bloc) => bloc.add(const HomeLoadMoreRequested()),
      expect: () => [
        const HomeLoaded(
          shows: page0Shows,
          currentPage: 0,
          hasReachedMax: false,
          isLoadingMore: true,
        ),
        const HomeLoaded(
          shows: page0Shows,
          currentPage: 0,
          hasReachedMax: true,
          isLoadingMore: false,
        ),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'preserves already loaded shows and exposes error on pagination failure',
      build: () {
        when(() => mockShowRepository.getShows(page: 1))
            .thenThrow(const ServerException('500 Internal Server Error'));
        return homeBloc;
      },
      seed: () => const HomeLoaded(
        shows: page0Shows,
        currentPage: 0,
        hasReachedMax: false,
      ),
      act: (bloc) => bloc.add(const HomeLoadMoreRequested()),
      expect: () => [
        const HomeLoaded(
          shows: page0Shows,
          currentPage: 0,
          hasReachedMax: false,
          isLoadingMore: true,
        ),
        const HomeLoaded(
          shows: page0Shows,
          currentPage: 0,
          hasReachedMax: false,
          isLoadingMore: false,
          loadMoreError: '500 Internal Server Error',
        ),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'retries load-more when HomeRetryRequested is triggered after pagination failure',
      build: () {
        when(() => mockShowRepository.getShows(page: 1))
            .thenAnswer((_) async => page1Shows);
        return homeBloc;
      },
      seed: () => const HomeLoaded(
        shows: page0Shows,
        currentPage: 0,
        hasReachedMax: false,
        loadMoreError: 'Temporary network glitch',
      ),
      act: (bloc) => bloc.add(const HomeRetryRequested()),
      expect: () => [
        const HomeLoaded(
          shows: page0Shows,
          currentPage: 0,
          hasReachedMax: false,
          isLoadingMore: true,
          loadMoreError: null,
        ),
        const HomeLoaded(
          shows: [...page0Shows, ...page1Shows],
          currentPage: 1,
          hasReachedMax: false,
          isLoadingMore: false,
        ),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'retries initial fetch when HomeRetryRequested is triggered from HomeError',
      build: () {
        when(() => mockShowRepository.getShows(page: 0))
            .thenAnswer((_) async => page0Shows);
        return homeBloc;
      },
      seed: () => const HomeError('Connection failed'),
      act: (bloc) => bloc.add(const HomeRetryRequested()),
      expect: () => [
        const HomeLoading(),
        const HomeLoaded(
          shows: page0Shows,
          currentPage: 0,
          hasReachedMax: false,
        ),
      ],
    );
  });
}
