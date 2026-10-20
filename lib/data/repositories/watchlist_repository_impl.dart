import '../../domain/entities/show.dart';
import '../../domain/repositories/watchlist_repository.dart';
import '../datasources/watchlist_local_data_source.dart';
import '../models/show_model.dart';

/// Implementation of [WatchlistRepository] persisting shows locally.
class WatchlistRepositoryImpl implements WatchlistRepository {
  final WatchlistLocalDataSource localDataSource;

  WatchlistRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Show>> getWatchlist() async {
    final models = await localDataSource.getWatchlist();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> addToWatchlist(Show show) async {
    final model = ShowModel.fromEntity(show);
    await localDataSource.saveShow(model);
  }

  @override
  Future<void> removeFromWatchlist(int showId) async {
    await localDataSource.removeShow(showId);
  }

  @override
  Future<bool> isShowInWatchlist(int showId) async {
    return await localDataSource.isShowInWatchlist(showId);
  }
}
