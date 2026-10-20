import 'package:flutter_test/flutter_test.dart';
import 'package:tv_maze_application/data/models/cast_model.dart';
import 'package:tv_maze_application/data/models/episode_model.dart';
import 'package:tv_maze_application/data/models/image_model.dart';
import 'package:tv_maze_application/data/models/rating_model.dart';
import 'package:tv_maze_application/data/models/show_model.dart';

void main() {
  group('ImageModel', () {
    test('parses image JSON correctly', () {
      final json = {
        'medium': 'https://static.tvmaze.com/medium.jpg',
        'original': 'https://static.tvmaze.com/original.jpg',
      };
      final model = ImageModel.fromJson(json);
      expect(model.medium, 'https://static.tvmaze.com/medium.jpg');
      expect(model.original, 'https://static.tvmaze.com/original.jpg');
      expect(model.preferredPoster, 'https://static.tvmaze.com/medium.jpg');
      expect(model.preferredBackdrop, 'https://static.tvmaze.com/original.jpg');
    });

    test('handles null image input gracefully', () {
      final model = ImageModel.fromJson(null);
      expect(model.medium, isNull);
      expect(model.original, isNull);
      expect(model.preferredPoster, isNull);
    });

    test('toJson serializes correctly', () {
      const model = ImageModel(medium: 'm.jpg', original: 'o.jpg');
      expect(model.toJson(), {'medium': 'm.jpg', 'original': 'o.jpg'});
    });
  });

  group('RatingModel', () {
    test('parses map rating object', () {
      final model = RatingModel.fromJson({'average': 8.5});
      expect(model.average, 8.5);
    });

    test('parses raw numeric rating', () {
      final model = RatingModel.fromJson(7);
      expect(model.average, 7.0);
    });

    test('handles null rating gracefully', () {
      final model = RatingModel.fromJson(null);
      expect(model.average, isNull);
    });

    test('toJson serializes correctly', () {
      const model = RatingModel(average: 9.1);
      expect(model.toJson(), {'average': 9.1});
    });
  });

  group('ShowModel', () {
    test('parses complete show JSON with all metadata and nested objects', () {
      final json = {
        'id': 1,
        'name': 'Under the Dome',
        'type': 'Scripted',
        'language': 'English',
        'genres': ['Drama', 'Science-Fiction'],
        'status': 'Ended',
        'runtime': 60,
        'premiered': '2013-06-24',
        'ended': '2015-09-10',
        'officialSite': 'http://www.cbs.com/shows/under-the-dome/',
        'rating': {'average': 6.5},
        'network': {'id': 2, 'name': 'CBS'},
        'webChannel': null,
        'image': {
          'medium': 'https://static.tvmaze.com/uploads/images/medium_portrait/0/1.jpg',
          'original': 'https://static.tvmaze.com/uploads/images/original_untouched/0/1.jpg',
        },
        'summary': '<p>Under the Dome is the story of a small town...</p>',
      };

      final model = ShowModel.fromJson(json);

      expect(model.id, 1);
      expect(model.name, 'Under the Dome');
      expect(model.type, 'Scripted');
      expect(model.language, 'English');
      expect(model.genres, ['Drama', 'Science-Fiction']);
      expect(model.status, 'Ended');
      expect(model.runtime, 60);
      expect(model.premiered, '2013-06-24');
      expect(model.ended, '2015-09-10');
      expect(model.officialSite, 'http://www.cbs.com/shows/under-the-dome/');
      expect(model.rating?.average, 6.5);
      expect(model.ratingAverage, 6.5);
      expect(model.networkName, 'CBS');
      expect(model.webChannelName, isNull);
      expect(model.channelOrNetwork, 'CBS');
      expect(model.image?.medium, 'https://static.tvmaze.com/uploads/images/medium_portrait/0/1.jpg');
      expect(model.posterUrl, 'https://static.tvmaze.com/uploads/images/medium_portrait/0/1.jpg');
      expect(model.backdropUrl, 'https://static.tvmaze.com/uploads/images/original_untouched/0/1.jpg');
      expect(model.summary, contains('Under the Dome'));
    });

    test('handles null and missing fields safely without throwing', () {
      final json = <String, dynamic>{
        'id': 42,
        'name': null,
        'image': null,
        'genres': null,
        'rating': null,
        'summary': null,
        'premiered': null,
        'ended': null,
        'status': null,
        'language': null,
        'network': null,
        'webChannel': null,
      };

      final model = ShowModel.fromJson(json);

      expect(model.id, 42);
      expect(model.name, 'Untitled Show');
      expect(model.image, isNull);
      expect(model.posterUrl, isNull);
      expect(model.genres, isEmpty);
      expect(model.rating, isNull);
      expect(model.ratingAverage, isNull);
      expect(model.summary, '');
      expect(model.premiered, isNull);
      expect(model.ended, isNull);
      expect(model.status, isNull);
      expect(model.language, isNull);
      expect(model.channelOrNetwork, isNull);
    });

    test('parses search response wrapper correctly: { score: 12.3, show: { ... } }', () {
      final searchWrapper = {
        'score': 17.5,
        'show': {
          'id': 139,
          'name': 'Girls',
          'genres': ['Drama', 'Romance'],
          'rating': {'average': 6.6},
          'webChannel': {'name': 'HBO Max'},
        },
      };

      final model = ShowModel.fromJson(searchWrapper);

      expect(model.id, 139);
      expect(model.name, 'Girls');
      expect(model.genres, ['Drama', 'Romance']);
      expect(model.ratingAverage, 6.6);
      expect(model.webChannelName, 'HBO Max');
      expect(model.channelOrNetwork, 'HBO Max');
    });

    test('persists and restores all show data via toJson roundtrip', () {
      const original = ShowModel(
        id: 77,
        name: 'Dark',
        genres: ['Mystery', 'Sci-Fi'],
        rating: RatingModel(average: 8.8),
        image: ImageModel(medium: 'dark_m.jpg', original: 'dark_o.jpg'),
        premiered: '2017-12-01',
        ended: '2020-06-27',
        status: 'Ended',
        language: 'German',
        networkName: 'Netflix',
      );

      final json = original.toJson();
      final restored = ShowModel.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.genres, original.genres);
      expect(restored.ratingAverage, 8.8);
      expect(restored.premiered, '2017-12-01');
      expect(restored.ended, '2020-06-27');
      expect(restored.status, 'Ended');
      expect(restored.language, 'German');
      expect(restored.networkName, 'Netflix');
      expect(restored.posterUrl, 'dark_m.jpg');
    });
  });

  group('CastModel', () {
    test('parses person and character data completely', () {
      final json = {
        'person': {
          'id': 1,
          'name': 'Mike Vogel',
          'image': {'medium': 'mike_m.jpg', 'original': 'mike_o.jpg'},
        },
        'character': {
          'id': 2,
          'name': 'Dale "Barbie" Barbara',
          'image': {'medium': 'barbie_m.jpg', 'original': 'barbie_o.jpg'},
        },
      };

      final model = CastModel.fromJson(json);

      expect(model.personId, 1);
      expect(model.personName, 'Mike Vogel');
      expect(model.personImage?.medium, 'mike_m.jpg');
      expect(model.characterId, 2);
      expect(model.characterName, 'Dale "Barbie" Barbara');
      expect(model.characterImage?.medium, 'barbie_m.jpg');
      expect(model.displayImage, 'mike_m.jpg');
    });

    test('handles missing character or person objects safely', () {
      final json = <String, dynamic>{};
      final model = CastModel.fromJson(json);

      expect(model.personId, 0);
      expect(model.personName, 'Unknown Actor');
      expect(model.characterId, isNull);
      expect(model.characterName, 'Unknown Character');
      expect(model.displayImage, isNull);
    });
  });

  group('EpisodeModel', () {
    test('parses episode data completely with ratings, images, and codes', () {
      final json = {
        'id': 1001,
        'name': 'Pilot',
        'season': 1,
        'number': 1,
        'airdate': '2013-06-24',
        'airtime': '22:00',
        'runtime': 60,
        'rating': {'average': 7.7},
        'image': {'medium': 'ep1_m.jpg', 'original': 'ep1_o.jpg'},
        'summary': '<p>Pilot episode</p>',
      };

      final model = EpisodeModel.fromJson(json);

      expect(model.id, 1001);
      expect(model.name, 'Pilot');
      expect(model.season, 1);
      expect(model.number, 1);
      expect(model.airdate, '2013-06-24');
      expect(model.airtime, '22:00');
      expect(model.runtime, 60);
      expect(model.rating?.average, 7.7);
      expect(model.ratingAverage, 7.7);
      expect(model.image?.medium, 'ep1_m.jpg');
      expect(model.thumbnailUrl, 'ep1_m.jpg');
      expect(model.episodeCode, 'S01E01');
      expect(model.summary, '<p>Pilot episode</p>');
    });

    test('handles special episodes with null episode number safely', () {
      final json = {
        'id': 1002,
        'name': 'Special Behind the Scenes',
        'season': 1,
        'number': null,
      };

      final model = EpisodeModel.fromJson(json);

      expect(model.id, 1002);
      expect(model.number, isNull);
      expect(model.episodeCode, 'S01E00');
      expect(model.rating, isNull);
      expect(model.image, isNull);
    });
  });
}
