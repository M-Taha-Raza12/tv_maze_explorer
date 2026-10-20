import 'package:equatable/equatable.dart';

/// Typed domain entity representing image URLs for posters, thumbnails, and backdrops.
class TvMazeImage extends Equatable {
  final String? medium;
  final String? original;

  const TvMazeImage({
    this.medium,
    this.original,
  });

  /// Preferred poster or thumbnail URL (medium preferred for cards, original as fallback).
  String? get preferredPoster => medium ?? original;

  /// Preferred backdrop or high-resolution URL (original preferred, medium as fallback).
  String? get preferredBackdrop => original ?? medium;

  @override
  List<Object?> get props => [medium, original];
}
