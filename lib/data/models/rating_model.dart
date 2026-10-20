import '../../domain/entities/tv_rating.dart';

/// Data model representing TVMaze ratings with robust numeric parsing and null safety.
class RatingModel extends TvMazeRating {
  const RatingModel({super.average});

  /// Factory constructor to safely parse rating objects or raw numbers.
  factory RatingModel.fromJson(dynamic json) {
    if (json == null) {
      return const RatingModel();
    }

    if (json is Map<String, dynamic>) {
      final avg = json['average'];
      if (avg is num) {
        return RatingModel(average: avg.toDouble());
      }
      return const RatingModel();
    }

    if (json is num) {
      return RatingModel(average: json.toDouble());
    }

    return const RatingModel();
  }

  Map<String, dynamic> toJson() {
    return {
      'average': average,
    };
  }

  static RatingModel? fromNullableJson(dynamic json) {
    if (json == null) return null;
    return RatingModel.fromJson(json);
  }
}
