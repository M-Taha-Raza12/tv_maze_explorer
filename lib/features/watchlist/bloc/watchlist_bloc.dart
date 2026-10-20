import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/watchlist_repository.dart';
import 'watchlist_event.dart';
import 'watchlist_state.dart';

/// BLoC managing personal watchlist persistence, addition, removal, and toggling.
class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  final WatchlistRepository watchlistRepository;

  WatchlistBloc({required this.watchlistRepository}) : super(const WatchlistInitial()) {
    on<LoadWatchlist>(_onLoadWatchlist);
    on<AddShowToWatchlist>(_onAddShow);
    on<RemoveShowFromWatchlist>(_onRemoveShow);
    on<ToggleWatchlist>(_onToggleWatchlist);
  }

  Future<void> _onLoadWatchlist(
    LoadWatchlist event,
    Emitter<WatchlistState> emit,
  ) async {
    emit(const WatchlistLoading());
    try {
      final shows = await watchlistRepository.getWatchlist();
      emit(WatchlistLoaded(shows));
    } catch (e) {
      emit(WatchlistError('Failed to load watchlist: $e'));
    }
  }

  Future<void> _onAddShow(
    AddShowToWatchlist event,
    Emitter<WatchlistState> emit,
  ) async {
    try {
      await watchlistRepository.addToWatchlist(event.show);
      final updated = await watchlistRepository.getWatchlist();
      emit(WatchlistLoaded(updated));
    } catch (e) {
      emit(WatchlistError('Failed to add show to watchlist: $e'));
    }
  }

  Future<void> _onRemoveShow(
    RemoveShowFromWatchlist event,
    Emitter<WatchlistState> emit,
  ) async {
    try {
      await watchlistRepository.removeFromWatchlist(event.showId);
      final updated = await watchlistRepository.getWatchlist();
      emit(WatchlistLoaded(updated));
    } catch (e) {
      emit(WatchlistError('Failed to remove show from watchlist: $e'));
    }
  }

  Future<void> _onToggleWatchlist(
    ToggleWatchlist event,
    Emitter<WatchlistState> emit,
  ) async {
    try {
      final isInWatchlist = await watchlistRepository.isShowInWatchlist(event.show.id);
      if (isInWatchlist) {
        await watchlistRepository.removeFromWatchlist(event.show.id);
      } else {
        await watchlistRepository.addToWatchlist(event.show);
      }
      final updated = await watchlistRepository.getWatchlist();
      emit(WatchlistLoaded(updated));
    } catch (e) {
      emit(WatchlistError('Failed to update watchlist: $e'));
    }
  }
}
