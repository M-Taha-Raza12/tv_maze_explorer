import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../domain/repositories/show_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

/// BLoC managing TV show discovery, pagination, and error recovery.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ShowRepository showRepository;

  HomeBloc({required this.showRepository}) : super(const HomeInitial()) {
    on<HomeShowsRequested>(_onShowsRequested);
    on<HomeLoadMoreRequested>(_onLoadMoreRequested);
    on<HomeRetryRequested>(_onRetryRequested);
  }

  Future<void> _onShowsRequested(
    HomeShowsRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    try {
      final shows = await showRepository.getShows(page: 0);
      emit(HomeLoaded(
        shows: shows,
        currentPage: 0,
        hasReachedMax: shows.isEmpty,
      ));
    } on ApiException catch (e) {
      emit(HomeError(e.message));
    } catch (e) {
      emit(HomeError('Failed to load shows: $e'));
    }
  }

  Future<void> _onLoadMoreRequested(
    HomeLoadMoreRequested event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! HomeLoaded) return;

    // Prevent duplicate load-more requests while one is already in progress or max reached
    if (currentState.isLoadingMore || currentState.hasReachedMax) return;

    emit(currentState.copyWith(isLoadingMore: true, loadMoreError: null));

    final nextPage = currentState.currentPage + 1;
    try {
      final newShows = await showRepository.getShows(page: nextPage);

      if (newShows.isEmpty) {
        // Stop pagination when no more results are available
        emit(currentState.copyWith(
          hasReachedMax: true,
          isLoadingMore: false,
        ));
      } else {
        // Append newly fetched shows while preserving existing ones
        emit(currentState.copyWith(
          shows: [...currentState.shows, ...newShows],
          currentPage: nextPage,
          hasReachedMax: false,
          isLoadingMore: false,
        ));
      }
    } on ApiException catch (e) {
      // Preserve already loaded shows and expose retryable loadMoreError
      emit(currentState.copyWith(
        isLoadingMore: false,
        loadMoreError: e.message,
      ));
    } catch (e) {
      emit(currentState.copyWith(
        isLoadingMore: false,
        loadMoreError: 'Failed to load more shows: $e',
      ));
    }
  }

  Future<void> _onRetryRequested(
    HomeRetryRequested event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is HomeLoaded && currentState.loadMoreError != null) {
      add(const HomeLoadMoreRequested());
    } else {
      add(const HomeShowsRequested());
    }
  }
}
