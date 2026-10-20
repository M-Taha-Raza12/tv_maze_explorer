import 'package:equatable/equatable.dart';
import '../../../domain/entities/show.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

/// Initial uninitialized state.
class HomeInitial extends HomeState {
  const HomeInitial();
}

/// Initial page loading state.
class HomeLoading extends HomeState {
  const HomeLoading();
}

/// Loaded state preserving the current shows and pagination metadata.
class HomeLoaded extends HomeState {
  final List<Show> shows;
  final int currentPage;
  final bool hasReachedMax;
  final bool isLoadingMore;
  final String? loadMoreError;

  const HomeLoaded({
    required this.shows,
    this.currentPage = 0,
    this.hasReachedMax = false,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  HomeLoaded copyWith({
    List<Show>? shows,
    int? currentPage,
    bool? hasReachedMax,
    bool? isLoadingMore,
    String? loadMoreError,
  }) {
    return HomeLoaded(
      shows: shows ?? this.shows,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreError: loadMoreError,
    );
  }

  @override
  List<Object?> get props => [
        shows,
        currentPage,
        hasReachedMax,
        isLoadingMore,
        loadMoreError,
      ];
}

/// Error state when the initial fetch fails.
class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
