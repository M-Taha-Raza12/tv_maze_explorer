import 'package:equatable/equatable.dart';
import 'tv_image.dart';
import 'tv_rating.dart';

/// Core domain entity representing a TV Show Episode.
class Episode extends Equatable {
  final int id;
  final String name;
  final int season;
  final int? number;
  final String? airdate;
  final String? airtime;
  final int? runtime;
  final TvMazeRating? rating;
  final TvMazeImage? image;
  final String summary;

  const Episode({
    required this.id,
    required this.name,
    required this.season,
    this.number,
    this.airdate,
    this.airtime,
    this.runtime,
    this.rating,
    this.image,
    this.summary = '',
  });

  /// Formatted episode code, e.g. `S01E05`.
  String get episodeCode {
    final s = season.toString().padLeft(2, '0');
    final e = (number ?? 0).toString().padLeft(2, '0');
    return 'S${s}E$e';
  }

  /// Preferred thumbnail image URL.
  String? get thumbnailUrl => image?.preferredPoster;

  /// Numeric rating value.
  double? get ratingAverage => rating?.average;

  @override
  List<Object?> get props => [
        id,
        name,
        season,
        number,
        airdate,
        airtime,
        runtime,
        rating,
        image,
        summary,
      ];
}
