import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../domain/repositories/show_repository.dart';
import 'search_event.dart';
import 'search_state.dart';

/// Event transformer that debounces events and cancels the previous event mapper execution.
EventTransformer<Event> debounceRestartable<Event>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).switchMap(mapper);
}

/// BLoC managing TV show search with debouncing (450ms) and stale-request protection.
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final ShowRepository showRepository;
  final Duration debounceDuration;

  CancelToken? _cancelToken;
  String _activeQuery = '';

  SearchBloc({
    required this.showRepository,
    this.debounceDuration = const Duration(milliseconds: 450),
  }) : super(const SearchInitial()) {
    on<SearchQueryChanged>(
      _onQueryChanged,
      transformer: debounceRestartable(debounceDuration),
    );
    on<SearchClearQuery>(_onClearQuery);
    on<SearchRetry>(_onRetry);
  }

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();

    if (query.isEmpty) {
      _cancelToken?.cancel('Query cleared');
      _activeQuery = '';
      emit(const SearchInitial());
      return;
    }

    _activeQuery = query;

    // Stale-request protection: cancel any existing in-flight network request
    _cancelToken?.cancel('New query initiated');
    _cancelToken = CancelToken();

    emit(SearchLoading(query));

    try {
      final results = await showRepository.searchShows(
        query,
        cancelToken: _cancelToken,
      );

      // Verify the response matches the current active query
      if (query != _activeQuery) return;

      if (results.isEmpty) {
        emit(SearchEmpty(query));
      } else {
        emit(SearchResultsLoaded(results: results, query: query));
      }
    } on DioException catch (dioError) {
      if (dioError.type == DioExceptionType.cancel) {
        // Request was cancelled in favor of a newer query; ignore silently
        return;
      }
      if (query == _activeQuery) {
        emit(SearchError(
          message: dioError.message ?? 'Search request failed.',
          query: query,
        ));
      }
    } on ApiException catch (e) {
      if (e.message.contains('cancelled') || e.message.contains('canceled')) return;
      if (query == _activeQuery) {
        emit(SearchError(message: e.message, query: query));
      }
    } catch (e) {
      if (query == _activeQuery) {
        emit(SearchError(message: 'Failed to search shows: $e', query: query));
      }
    }
  }

  void _onClearQuery(
    SearchClearQuery event,
    Emitter<SearchState> emit,
  ) {
    _cancelToken?.cancel('Query cleared by user');
    _activeQuery = '';
    emit(const SearchInitial());
  }

  Future<void> _onRetry(
    SearchRetry event,
    Emitter<SearchState> emit,
  ) async {
    if (_activeQuery.isNotEmpty) {
      add(SearchQueryChanged(_activeQuery));
    }
  }

  @override
  Future<void> close() {
    _cancelToken?.cancel('SearchBloc closed');
    return super.close();
  }
}
