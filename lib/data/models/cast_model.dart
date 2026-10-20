import '../../domain/entities/cast_member.dart';
import 'image_model.dart';

/// Typed, null-safe data model for cast members returned from TVMaze API.
class CastModel extends CastMember {
  const CastModel({
    required super.personId,
    required super.personName,
    super.personImage,
    super.characterId,
    required super.characterName,
    super.characterImage,
  });

  factory CastModel.fromJson(Map<String, dynamic> json) {
    final person = json['person'] as Map<String, dynamic>? ?? {};
    final character = json['character'] as Map<String, dynamic>? ?? {};

    // Person image
    ImageModel? personImg;
    if (person['image'] is Map<String, dynamic>) {
      personImg = ImageModel.fromJson(person['image'] as Map<String, dynamic>);
    }

    // Character image
    ImageModel? charImg;
    if (character['image'] is Map<String, dynamic>) {
      charImg = ImageModel.fromJson(character['image'] as Map<String, dynamic>);
    }

    return CastModel(
      personId: person['id'] is num ? (person['id'] as num).toInt() : 0,
      personName: person['name'] as String? ?? 'Unknown Actor',
      personImage: personImg,
      characterId: character['id'] is num ? (character['id'] as num).toInt() : null,
      characterName: character['name'] as String? ?? 'Unknown Character',
      characterImage: charImg,
    );
  }

  CastMember toEntity() => this;
}
