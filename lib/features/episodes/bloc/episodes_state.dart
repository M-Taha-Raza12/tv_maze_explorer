import 'package:equatable/equatable.dart';
import '../../../domain/entities/episode.dart';

abstract class EpisodesState extends Equatable {
  const EpisodesState();

  @override
  List<Object?> get props => [];
}

class EpisodesInitial extends EpisodesState {
  const EpisodesInitial();
}

class EpisodesLoading extends EpisodesState {
  const EpisodesLoading();
}

class EpisodesLoaded extends EpisodesState {
  final List<Episode> allEpisodes;
  final List<int> seasons;
  final int selectedSeason;
  final List<Episode> seasonEpisodes;

  const EpisodesLoaded({
    required this.allEpisodes,
    required this.seasons,
    required this.selectedSeason,
    required this.seasonEpisodes,
  });

  EpisodesLoaded copyWith({
    List<Episode>? allEpisodes,
    List<int>? seasons,
    int? selectedSeason,
    List<Episode>? seasonEpisodes,
  }) {
    return EpisodesLoaded(
      allEpisodes: allEpisodes ?? this.allEpisodes,
      seasons: seasons ?? this.seasons,
      selectedSeason: selectedSeason ?? this.selectedSeason,
      seasonEpisodes: seasonEpisodes ?? this.seasonEpisodes,
    );
  }

  @override
  List<Object?> get props => [
        allEpisodes,
        seasons,
        selectedSeason,
        seasonEpisodes,
      ];
}

class EpisodesEmpty extends EpisodesState {
  const EpisodesEmpty();
}

class EpisodesError extends EpisodesState {
  final String message;

  const EpisodesError(this.message);

  @override
  List<Object?> get props => [message];
}
