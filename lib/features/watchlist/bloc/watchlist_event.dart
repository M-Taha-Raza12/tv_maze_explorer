import 'package:equatable/equatable.dart';
import '../../../domain/entities/show.dart';

abstract class WatchlistEvent extends Equatable {
  const WatchlistEvent();

  @override
  List<Object?> get props => [];
}

class LoadWatchlist extends WatchlistEvent {
  const LoadWatchlist();
}

class AddShowToWatchlist extends WatchlistEvent {
  final Show show;

  const AddShowToWatchlist(this.show);

  @override
  List<Object?> get props => [show];
}

class RemoveShowFromWatchlist extends WatchlistEvent {
  final int showId;

  const RemoveShowFromWatchlist(this.showId);

  @override
  List<Object?> get props => [showId];
}

class ToggleWatchlist extends WatchlistEvent {
  final Show show;

  const ToggleWatchlist(this.show);

  @override
  List<Object?> get props => [show];
}
