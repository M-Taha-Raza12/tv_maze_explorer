import '../../domain/entities/episode.dart';
import 'image_model.dart';
import 'rating_model.dart';

/// Typed, null-safe data model for episodes returned from TVMaze API.
class EpisodeModel extends Episode {
  const EpisodeModel({
    required super.id,
    required super.name,
    required super.season,
    super.number,
    super.airdate,
    super.airtime,
    super.runtime,
    super.rating,
    super.image,
    super.summary,
  });

  factory EpisodeModel.fromJson(Map<String, dynamic> json) {
    // Rating
    RatingModel? parsedRating;
    if (json['rating'] != null) {
      parsedRating = RatingModel.fromJson(json['rating']);
    }

    // Image
    ImageModel? parsedImage;
    if (json['image'] is Map<String, dynamic>) {
      parsedImage = ImageModel.fromJson(json['image'] as Map<String, dynamic>);
    }

    return EpisodeModel(
      id: json['id'] is num ? (json['id'] as num).toInt() : 0,
      name: json['name'] as String? ?? 'Untitled Episode',
      season: json['season'] is num ? (json['season'] as num).toInt() : 1,
      number: json['number'] is num ? (json['number'] as num).toInt() : null,
      airdate: json['airdate'] as String?,
      airtime: json['airtime'] as String?,
      runtime: json['runtime'] is num ? (json['runtime'] as num).toInt() : null,
      rating: parsedRating,
      image: parsedImage,
      summary: json['summary'] as String? ?? '',
    );
  }

  Episode toEntity() => this;
}
