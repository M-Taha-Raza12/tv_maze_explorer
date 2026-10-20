import '../../domain/entities/tv_image.dart';

/// Data model representing image URLs with JSON serialization and null safety.
class ImageModel extends TvMazeImage {
  const ImageModel({
    super.medium,
    super.original,
  });

  /// Factory constructor to safely parse image objects from TVMaze API or local storage.
  factory ImageModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ImageModel();
    }
    return ImageModel(
      medium: json['medium'] as String?,
      original: json['original'] as String?,
    );
  }

  /// Converts entity or model to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'medium': medium,
      'original': original,
    };
  }

  static ImageModel? fromNullableJson(dynamic json) {
    if (json == null || json is! Map<String, dynamic>) {
      return null;
    }
    return ImageModel.fromJson(json);
  }
}
