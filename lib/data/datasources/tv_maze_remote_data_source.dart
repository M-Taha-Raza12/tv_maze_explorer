import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_exceptions.dart';
import '../models/cast_model.dart';
import '../models/episode_model.dart';
import '../models/show_model.dart';

/// Contract for TVMaze remote API operations.
abstract class TvMazeRemoteDataSource {
  /// Fetches a paginated list of shows from `/shows?page={page}`.
  Future<List<ShowModel>> getShows({int page = 0});

  /// Searches shows by keyword or title from `/search/shows?q={query}`.
  Future<List<ShowModel>> searchShows(String query, {CancelToken? cancelToken});

  /// Fetches complete details of a show from `/shows/{id}`.
  Future<ShowModel> getShowDetails(int showId);

  /// Fetches cast members for a given show from `/shows/{id}/cast`.
  Future<List<CastModel>> getShowCast(int showId);

  /// Fetches all episodes of a given show from `/shows/{id}/episodes`.
  Future<List<EpisodeModel>> getShowEpisodes(int showId);
}

/// Implementation of [TvMazeRemoteDataSource] using [ApiClient].
class TvMazeRemoteDataSourceImpl implements TvMazeRemoteDataSource {
  final ApiClient client;

  TvMazeRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ShowModel>> getShows({int page = 0}) async {
    try {
      final data = await client.get(
        ApiConstants.showsEndpoint,
        queryParameters: {'page': page},
      );

      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((json) => ShowModel.fromJson(json))
            .toList();
      }
      throw const DataParsingException('Invalid shows response format: expected a JSON list.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw DataParsingException('Failed to process shows list: $e');
    }
  }

  @override
  Future<List<ShowModel>> searchShows(String query, {CancelToken? cancelToken}) async {
    try {
      final data = await client.get(
        ApiConstants.searchShowsEndpoint,
        queryParameters: {'q': query},
        cancelToken: cancelToken,
      );

      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((item) => ShowModel.fromJson(item))
            .toList();
      }
      throw const DataParsingException('Invalid search response format: expected a JSON list.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw DataParsingException('Failed to process search results: $e');
    }
  }

  @override
  Future<ShowModel> getShowDetails(int showId) async {
    try {
      final data = await client.get(ApiConstants.showDetailsEndpoint(showId));
      if (data is Map<String, dynamic>) {
        return ShowModel.fromJson(data);
      }
      throw const DataParsingException('Invalid show details format: expected a JSON map.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw DataParsingException('Failed to process show details: $e');
    }
  }

  @override
  Future<List<CastModel>> getShowCast(int showId) async {
    try {
      final data = await client.get(ApiConstants.showCastEndpoint(showId));
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((json) => CastModel.fromJson(json))
            .toList();
      }
      throw const DataParsingException('Invalid cast response format: expected a JSON list.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw DataParsingException('Failed to process cast list: $e');
    }
  }

  @override
  Future<List<EpisodeModel>> getShowEpisodes(int showId) async {
    try {
      final data = await client.get(ApiConstants.showEpisodesEndpoint(showId));
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((json) => EpisodeModel.fromJson(json))
            .toList();
      }
      throw const DataParsingException('Invalid episode response format: expected a JSON list.');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw DataParsingException('Failed to process episode list: $e');
    }
  }
}
