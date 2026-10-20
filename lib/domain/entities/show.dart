import 'package:equatable/equatable.dart';
import 'tv_image.dart';
import 'tv_rating.dart';

/// Core domain entity representing a TV Show with all required metadata.
class Show extends Equatable {
  final int id;
  final String name;
  final TvMazeImage? image;
  final List<String> genres;
  final TvMazeRating? rating;
  final String summary;
  final String? premiered;
  final String? ended;
  final String? status;
  final String? language;
  final String? networkName;
  final String? webChannelName;
  final String? type;
  final int? runtime;
  final String? officialSite;

  const Show({
    required this.id,
    required this.name,
    this.image,
    this.genres = const [],
    this.rating,
    this.summary = '',
    this.premiered,
    this.ended,
    this.status,
    this.language,
    this.networkName,
    this.webChannelName,
    this.type,
    this.runtime,
    this.officialSite,
  });

  /// Convenience getter for average rating numeric value.
  double? get ratingAverage => rating?.average;

  /// Returns broadcasting network or web streaming service.
  String? get channelOrNetwork => networkName ?? webChannelName;

  /// Preferred poster image URL.
  String? get posterUrl => image?.preferredPoster;

  /// Preferred backdrop image URL.
  String? get backdropUrl => image?.preferredBackdrop;

  @override
  List<Object?> get props => [
        id,
        name,
        image,
        genres,
        rating,
        summary,
        premiered,
        ended,
        status,
        language,
        networkName,
        webChannelName,
        type,
        runtime,
        officialSite,
      ];
}
