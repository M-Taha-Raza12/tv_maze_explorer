import 'package:dio/dio.dart';
import '../../domain/entities/cast_member.dart';
import '../../domain/entities/episode.dart';
import '../../domain/entities/show.dart';
import '../../domain/repositories/show_repository.dart';
import '../datasources/tv_maze_remote_data_source.dart';

/// Implementation of [ShowRepository] coordinating remote data access.
class ShowRepositoryImpl implements ShowRepository {
  final TvMazeRemoteDataSource remoteDataSource;

  ShowRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Show>> getShows({int page = 0}) async {
    final models = await remoteDataSource.getShows(page: page);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Show>> searchShows(String query, {CancelToken? cancelToken}) async {
    final models = await remoteDataSource.searchShows(query, cancelToken: cancelToken);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<Show> getShowDetails(int showId) async {
    final model = await remoteDataSource.getShowDetails(showId);
    return model.toEntity();
  }

  @override
  Future<List<CastMember>> getShowCast(int showId) async {
    final models = await remoteDataSource.getShowCast(showId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Episode>> getShowEpisodes(int showId) async {
    final models = await remoteDataSource.getShowEpisodes(showId);
    return models.map((m) => m.toEntity()).toList();
  }
}
