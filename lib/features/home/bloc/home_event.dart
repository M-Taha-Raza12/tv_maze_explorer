import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched to fetch the initial page (page 0) of TV shows.
class HomeShowsRequested extends HomeEvent {
  const HomeShowsRequested();
}

/// Dispatched when the user scrolls near the bottom to request the next page.
class HomeLoadMoreRequested extends HomeEvent {
  const HomeLoadMoreRequested();
}

/// Dispatched when the user triggers a retry following a loading error.
class HomeRetryRequested extends HomeEvent {
  const HomeRetryRequested();
}
