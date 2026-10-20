import 'package:equatable/equatable.dart';

abstract class EpisodesEvent extends Equatable {
  const EpisodesEvent();

  @override
  List<Object?> get props => [];
}

class EpisodesRequested extends EpisodesEvent {
  final int showId;

  const EpisodesRequested(this.showId);

  @override
  List<Object?> get props => [showId];
}

class SeasonSelected extends EpisodesEvent {
  final int season;

  const SeasonSelected(this.season);

  @override
  List<Object?> get props => [season];
}

class EpisodesRetryRequested extends EpisodesEvent {
  final int showId;

  const EpisodesRetryRequested(this.showId);

  @override
  List<Object?> get props => [showId];
}
