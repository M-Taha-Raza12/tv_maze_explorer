import 'package:equatable/equatable.dart';

/// Typed domain entity representing a TVMaze average score rating.
class TvMazeRating extends Equatable {
  final double? average;

  const TvMazeRating({this.average});

  @override
  List<Object?> get props => [average];
}
