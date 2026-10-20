import 'package:dio/dio.dart';
import '../entities/show.dart';
import '../entities/cast_member.dart';
import '../entities/episode.dart';

/// Repository interface for TV show data operations.
abstract class ShowRepository {
  /// Fetches a paginated list of shows. [page] starts from 0.
  Future<List<Show>> getShows({int page = 0});

  /// Searches shows by title or keyword.
  Future<List<Show>> searchShows(String query, {CancelToken? cancelToken});

  /// Fetches complete details of a single show by its ID.
  Future<Show> getShowDetails(int showId);

  /// Fetches cast members for a given show.
  Future<List<CastMember>> getShowCast(int showId);

  /// Fetches all episodes of a given show.
  Future<List<Episode>> getShowEpisodes(int showId);
}
