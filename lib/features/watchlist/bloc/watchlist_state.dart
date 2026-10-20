import 'package:equatable/equatable.dart';
import '../../../domain/entities/show.dart';

abstract class WatchlistState extends Equatable {
  const WatchlistState();

  @override
  List<Object?> get props => [];
}

class WatchlistInitial extends WatchlistState {
  const WatchlistInitial();
}

class WatchlistLoading extends WatchlistState {
  const WatchlistLoading();
}

class WatchlistLoaded extends WatchlistState {
  final List<Show> shows;

  const WatchlistLoaded(this.shows);

  bool containsShow(int showId) {
    return shows.any((s) => s.id == showId);
  }

  @override
  List<Object?> get props => [shows];
}

class WatchlistError extends WatchlistState {
  final String message;

  const WatchlistError(this.message);

  @override
  List<Object?> get props => [message];
}
