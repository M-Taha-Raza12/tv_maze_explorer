import '../entities/show.dart';

/// Repository interface for local watchlist persistence.
abstract class WatchlistRepository {
  /// Retrieves all saved watchlist shows.
  Future<List<Show>> getWatchlist();

  /// Adds a show to the watchlist.
  Future<void> addToWatchlist(Show show);

  /// Removes a show from the watchlist by ID.
  Future<void> removeFromWatchlist(int showId);

  /// Checks if a show is in the watchlist.
  Future<bool> isShowInWatchlist(int showId);
}
