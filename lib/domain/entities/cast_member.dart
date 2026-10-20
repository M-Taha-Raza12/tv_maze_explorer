import 'package:equatable/equatable.dart';
import 'tv_image.dart';

/// Core domain entity representing a TV Show Cast Member with person & character details.
class CastMember extends Equatable {
  final int personId;
  final String personName;
  final TvMazeImage? personImage;
  final int? characterId;
  final String characterName;
  final TvMazeImage? characterImage;

  const CastMember({
    required this.personId,
    required this.personName,
    this.personImage,
    this.characterId,
    required this.characterName,
    this.characterImage,
  });

  /// Returns character image if available, else actor photo URL.
  String? get displayImage =>
      personImage?.preferredPoster ?? characterImage?.preferredPoster;

  @override
  List<Object?> get props => [
        personId,
        personName,
        personImage,
        characterId,
        characterName,
        characterImage,
      ];
}
