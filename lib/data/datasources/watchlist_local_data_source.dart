import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/show_model.dart';

/// Contract for persistent local watchlist operations.
abstract class WatchlistLocalDataSource {
  Future<List<ShowModel>> getWatchlist();
  Future<void> saveShow(ShowModel show);
  Future<void> removeShow(int showId);
  Future<bool> isShowInWatchlist(int showId);
}

/// SharedPreferences implementation of [WatchlistLocalDataSource].
class WatchlistLocalDataSourceImpl implements WatchlistLocalDataSource {
  static const String _watchlistKey = 'tvmaze_watchlist_shows';
  final SharedPreferences prefs;

  WatchlistLocalDataSourceImpl({required this.prefs});

  @override
  Future<List<ShowModel>> getWatchlist() async {
    final rawJson = prefs.getString(_watchlistKey);
    if (rawJson == null || rawJson.trim().isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map((item) => ShowModel.fromJson(item))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveShow(ShowModel show) async {
    final list = await getWatchlist();
    // Prevent duplicate entries
    list.removeWhere((item) => item.id == show.id);
    list.insert(0, show);

    final encoded = jsonEncode(list.map((item) => item.toJson()).toList());
    await prefs.setString(_watchlistKey, encoded);
  }

  @override
  Future<void> removeShow(int showId) async {
    final list = await getWatchlist();
    list.removeWhere((item) => item.id == showId);

    final encoded = jsonEncode(list.map((item) => item.toJson()).toList());
    await prefs.setString(_watchlistKey, encoded);
  }

  @override
  Future<bool> isShowInWatchlist(int showId) async {
    final list = await getWatchlist();
    return list.any((item) => item.id == showId);
  }
}
