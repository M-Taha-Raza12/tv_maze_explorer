import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tv_maze_application/core/network/api_exceptions.dart';
import 'package:tv_maze_application/domain/entities/show.dart';
import 'package:tv_maze_application/domain/repositories/show_repository.dart';
import 'package:tv_maze_application/features/search/bloc/search_bloc.dart';
import 'package:tv_maze_application/features/search/bloc/search_event.dart';
import 'package:tv_maze_application/features/search/bloc/search_state.dart';

class MockShowRepository extends Mock implements ShowRepository {}

void main() {
  late MockShowRepository mockShowRepository;
  late SearchBloc searchBloc;

  setUp(() {
    mockShowRepository = MockShowRepository();
    searchBloc = SearchBloc(
      showRepository: mockShowRepository,
      debounceDuration: Duration.zero,
    );
  });

  tearDown(() {
    searchBloc.close();
  });

  const breakingBadShows = [
    Show(id: 169, name: 'Breaking Bad'),
  ];

  const betterCallSaulShows = [
    Show(id: 618, name: 'Better Call Saul'),
  ];

  group('SearchBloc', () {
    test('initial state is SearchInitial', () {
      expect(searchBloc.state, const SearchInitial());
    });

    blocTest<SearchBloc, SearchState>(
      'clears query and resets to SearchInitial when query is empty whitespace',
      build: () => searchBloc,
      act: (bloc) => bloc.add(const SearchQueryChanged('   ')),
      expect: () => [const SearchInitial()],
    );

    blocTest<SearchBloc, SearchState>(
      'emits [SearchLoading, SearchResultsLoaded] on successful search matches',
      build: () {
        when(() => mockShowRepository.searchShows('Breaking', cancelToken: any(named: 'cancelToken')))
            .thenAnswer((_) async => breakingBadShows);
        return searchBloc;
      },
      act: (bloc) => bloc.add(const SearchQueryChanged('Breaking')),
      expect: () => [
        const SearchLoading('Breaking'),
        const SearchResultsLoaded(results: breakingBadShows, query: 'Breaking'),
      ],
      verify: (_) {
        verify(() => mockShowRepository.searchShows('Breaking', cancelToken: any(named: 'cancelToken'))).called(1);
      },
    );

    blocTest<SearchBloc, SearchState>(
      'emits [SearchLoading, SearchEmpty] when search returns no matches',
      build: () {
        when(() => mockShowRepository.searchShows('NonExistentShow123', cancelToken: any(named: 'cancelToken')))
            .thenAnswer((_) async => []);
        return searchBloc;
      },
      act: (bloc) => bloc.add(const SearchQueryChanged('NonExistentShow123')),
      expect: () => [
        const SearchLoading('NonExistentShow123'),
        const SearchEmpty('NonExistentShow123'),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'emits [SearchLoading, SearchError] on API network failure and provides retry',
      build: () {
        when(() => mockShowRepository.searchShows('ErrorShow', cancelToken: any(named: 'cancelToken')))
            .thenThrow(const NetworkException('No connection to TVMaze'));
        return searchBloc;
      },
      act: (bloc) => bloc.add(const SearchQueryChanged('ErrorShow')),
      expect: () => [
        const SearchLoading('ErrorShow'),
        const SearchError(message: 'No connection to TVMaze', query: 'ErrorShow'),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'SearchClearQuery resets state to SearchInitial immediately',
      build: () => searchBloc,
      seed: () => const SearchResultsLoaded(results: breakingBadShows, query: 'Breaking'),
      act: (bloc) => bloc.add(const SearchClearQuery()),
      expect: () => [const SearchInitial()],
    );

    test('stale-query protection: newer query cancels and prevents slower earlier response from replacing results', () async {
      final debouncedBloc = SearchBloc(
        showRepository: mockShowRepository,
        debounceDuration: const Duration(milliseconds: 50),
      );

      final query1Completer = Completer<List<Show>>();
      when(() => mockShowRepository.searchShows('query1', cancelToken: any(named: 'cancelToken')))
          .thenAnswer((_) => query1Completer.future);

      when(() => mockShowRepository.searchShows('query2', cancelToken: any(named: 'cancelToken')))
          .thenAnswer((_) async => betterCallSaulShows);

      // Dispatch first query
      debouncedBloc.add(const SearchQueryChanged('query1'));
      await Future.delayed(const Duration(milliseconds: 60));

      // Dispatch second query before query1 completes
      debouncedBloc.add(const SearchQueryChanged('query2'));
      await Future.delayed(const Duration(milliseconds: 60));

      // Resolve query1 late
      query1Completer.complete(breakingBadShows);
      await Future.delayed(const Duration(milliseconds: 20));

      // State must reflect query2, NOT query1!
      expect(debouncedBloc.state, isA<SearchResultsLoaded>());
      final loadedState = debouncedBloc.state as SearchResultsLoaded;
      expect(loadedState.query, 'query2');
      expect(loadedState.results, betterCallSaulShows);

      await debouncedBloc.close();
    });
  });
}
