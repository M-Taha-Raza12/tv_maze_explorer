import '../../domain/entities/show.dart';
import 'image_model.dart';
import 'rating_model.dart';

/// Typed, null-safe data model for TV shows supporting API and local storage formats.
class ShowModel extends Show {
  const ShowModel({
    required super.id,
    required super.name,
    super.image,
    super.genres,
    super.rating,
    super.summary,
    super.premiered,
    super.ended,
    super.status,
    super.language,
    super.networkName,
    super.webChannelName,
    super.type,
    super.runtime,
    super.officialSite,
  });

  /// Factory constructor parsing TVMaze JSON (or search wrapper: { score: ..., show: { ... } }).
  factory ShowModel.fromJson(Map<String, dynamic> json) {
    // TVMaze search endpoints return items wrapped in { score: 12.3, show: { ... } }
    final Map<String, dynamic> data = json.containsKey('show') && json['show'] is Map<String, dynamic>
        ? json['show'] as Map<String, dynamic>
        : json;

    // Parse image
    ImageModel? parsedImage;
    if (data['image'] is Map<String, dynamic>) {
      parsedImage = ImageModel.fromJson(data['image'] as Map<String, dynamic>);
    } else if (data['imageMedium'] != null || data['imageOriginal'] != null) {
      parsedImage = ImageModel(
        medium: data['imageMedium'] as String?,
        original: data['imageOriginal'] as String?,
      );
    }

    // Parse rating
    RatingModel? parsedRating;
    if (data['rating'] != null) {
      parsedRating = RatingModel.fromJson(data['rating']);
    }

    // Parse genres safely
    List<String> parsedGenres = [];
    if (data['genres'] is List) {
      parsedGenres = (data['genres'] as List)
          .where((e) => e != null)
          .map((e) => e.toString())
          .toList();
    }

    // Network name extraction
    String? netName;
    if (data['network'] is Map<String, dynamic>) {
      netName = (data['network'] as Map<String, dynamic>)['name'] as String?;
    } else if (data['networkName'] is String) {
      netName = data['networkName'] as String?;
    }

    // Web channel name extraction
    String? webName;
    if (data['webChannel'] is Map<String, dynamic>) {
      webName = (data['webChannel'] as Map<String, dynamic>)['name'] as String?;
    } else if (data['webChannelName'] is String) {
      webName = data['webChannelName'] as String?;
    }

    return ShowModel(
      id: data['id'] is num ? (data['id'] as num).toInt() : 0,
      name: data['name'] as String? ?? 'Untitled Show',
      image: parsedImage,
      genres: parsedGenres,
      rating: parsedRating,
      summary: data['summary'] as String? ?? '',
      premiered: data['premiered'] as String?,
      ended: data['ended'] as String?,
      status: data['status'] as String?,
      language: data['language'] as String?,
      networkName: netName,
      webChannelName: webName,
      type: data['type'] as String?,
      runtime: data['runtime'] is num ? (data['runtime'] as num).toInt() : null,
      officialSite: data['officialSite'] as String?,
    );
  }

  /// Converts a [Show] domain entity to a [ShowModel].
  factory ShowModel.fromEntity(Show show) {
    return ShowModel(
      id: show.id,
      name: show.name,
      image: show.image != null
          ? ImageModel(medium: show.image?.medium, original: show.image?.original)
          : null,
      genres: show.genres,
      rating: show.rating != null
          ? RatingModel(average: show.rating?.average)
          : null,
      summary: show.summary,
      premiered: show.premiered,
      ended: show.ended,
      status: show.status,
      language: show.language,
      networkName: show.networkName,
      webChannelName: show.webChannelName,
      type: show.type,
      runtime: show.runtime,
      officialSite: show.officialSite,
    );
  }

  /// Converts the model to JSON for persistent storage in SharedPreferences.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': (image != null)
          ? {'medium': image?.medium, 'original': image?.original}
          : null,
      'genres': genres,
      'rating': (rating != null) ? {'average': rating?.average} : null,
      'summary': summary,
      'premiered': premiered,
      'ended': ended,
      'status': status,
      'language': language,
      'networkName': networkName,
      'webChannelName': webChannelName,
      'type': type,
      'runtime': runtime,
      'officialSite': officialSite,
    };
  }

  Show toEntity() => this;
}
