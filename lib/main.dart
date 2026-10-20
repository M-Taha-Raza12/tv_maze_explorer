import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'data/datasources/watchlist_local_data_source.dart';
import 'data/repositories/watchlist_repository_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set immersive dark theme styling for Android/iOS system bars
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF141A29),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize persistent local storage foundation
  final prefs = await SharedPreferences.getInstance();
  final watchlistRepo = WatchlistRepositoryImpl(
    localDataSource: WatchlistLocalDataSourceImpl(prefs: prefs),
  );

  runApp(TvMazeApp(
    prefs: prefs,
    watchlistRepository: watchlistRepo,
  ));
}
