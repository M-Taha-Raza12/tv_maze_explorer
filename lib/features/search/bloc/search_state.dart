import 'package:equatable/equatable.dart';
import '../../../domain/entities/show.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {
  const SearchInitial();
}

class SearchLoading extends SearchState {
  final String query;

  const SearchLoading(this.query);

  @override
  List<Object?> get props => [query];
}

class SearchResultsLoaded extends SearchState {
  final List<Show> results;
  final String query;

  const SearchResultsLoaded({
    required this.results,
    required this.query,
  });

  @override
  List<Object?> get props => [results, query];
}

class SearchEmpty extends SearchState {
  final String query;

  const SearchEmpty(this.query);

  @override
  List<Object?> get props => [query];
}

class SearchError extends SearchState {
  final String message;
  final String query;

  const SearchError({
    required this.message,
    required this.query,
  });

  @override
  List<Object?> get props => [message, query];
}
