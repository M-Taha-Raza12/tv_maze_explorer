import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/network/api_exceptions.dart';
import '../../../domain/entities/episode.dart';
import '../../../domain/repositories/show_repository.dart';
import 'episodes_event.dart';
import 'episodes_state.dart';

/// BLoC managing TV show episodes grouping by season, season selection, and error recovery.
class EpisodesBloc extends Bloc<EpisodesEvent, EpisodesState> {
  final ShowRepository showRepository;

  EpisodesBloc({required this.showRepository}) : super(const EpisodesInitial()) {
    on<EpisodesRequested>(_onEpisodesRequested);
    on<SeasonSelected>(_onSeasonSelected);
    on<EpisodesRetryRequested>(_onEpisodesRetryRequested);
  }

  Future<void> _onEpisodesRequested(
    EpisodesRequested event,
    Emitter<EpisodesState> emit,
  ) async {
    emit(const EpisodesLoading());
    try {
      final episodes = await showRepository.getShowEpisodes(event.showId);

      if (episodes.isEmpty) {
        emit(const EpisodesEmpty());
        return;
      }

      // Group unique seasons in ascending order
      final seasonsSet = <int>{};
      for (final ep in episodes) {
        seasonsSet.add(ep.season);
      }
      final seasons = seasonsSet.toList()..sort();

      final initialSeason = seasons.isNotEmpty ? seasons.first : 1;
      final filteredEpisodes = _filterBySeason(episodes, initialSeason);

      emit(EpisodesLoaded(
        allEpisodes: episodes,
        seasons: seasons,
        selectedSeason: initialSeason,
        seasonEpisodes: filteredEpisodes,
      ));
    } on ApiException catch (e) {
      emit(EpisodesError(e.message));
    } catch (e) {
      emit(EpisodesError('Failed to load episodes: $e'));
    }
  }

  void _onSeasonSelected(
    SeasonSelected event,
    Emitter<EpisodesState> emit,
  ) {
    final currentState = state;
    if (currentState is! EpisodesLoaded) return;
    if (currentState.selectedSeason == event.season) return;

    final filtered = _filterBySeason(currentState.allEpisodes, event.season);
    emit(currentState.copyWith(
      selectedSeason: event.season,
      seasonEpisodes: filtered,
    ));
  }

  Future<void> _onEpisodesRetryRequested(
    EpisodesRetryRequested event,
    Emitter<EpisodesState> emit,
  ) async {
    add(EpisodesRequested(event.showId));
  }

  List<Episode> _filterBySeason(List<Episode> episodes, int season) {
    return episodes.where((ep) => ep.season == season).toList();
  }
}
