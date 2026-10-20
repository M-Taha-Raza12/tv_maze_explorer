import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/network/api_client.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/tv_maze_remote_data_source.dart';
import 'data/datasources/watchlist_local_data_source.dart';
import 'data/repositories/show_repository_impl.dart';
import 'data/repositories/watchlist_repository_impl.dart';
import 'domain/repositories/show_repository.dart';
import 'domain/repositories/watchlist_repository.dart';
import 'features/home/bloc/home_bloc.dart';
import 'features/home/bloc/home_event.dart';
import 'features/search/bloc/search_bloc.dart';
import 'features/watchlist/bloc/watchlist_bloc.dart';
import 'features/watchlist/bloc/watchlist_event.dart';

/// Root application widget configuring dependencies, BLoCs, theme, and router.
class TvMazeApp extends StatelessWidget {
  final ShowRepository? showRepository;
  final WatchlistRepository? watchlistRepository;
  final SharedPreferences? prefs;
  final RouterConfig<Object>? routerConfig;

  const TvMazeApp({
    super.key,
    this.showRepository,
    this.watchlistRepository,
    this.prefs,
    this.routerConfig,
  });

  @override
  Widget build(BuildContext context) {
    // Fallback instances if not provided (e.g. in standalone runs)
    final effectiveShowRepo = showRepository ??
        ShowRepositoryImpl(
          remoteDataSource: TvMazeRemoteDataSourceImpl(client: ApiClient()),
        );

    final effectiveWatchlistRepo = watchlistRepository ??
        (prefs != null
            ? WatchlistRepositoryImpl(
                localDataSource: WatchlistLocalDataSourceImpl(prefs: prefs!),
              )
            : null);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ShowRepository>.value(value: effectiveShowRepo),
        if (effectiveWatchlistRepo != null)
          RepositoryProvider<WatchlistRepository>.value(value: effectiveWatchlistRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<HomeBloc>(
            create: (_) => HomeBloc(showRepository: effectiveShowRepo)
              ..add(const HomeShowsRequested()),
          ),
          BlocProvider<SearchBloc>(
            create: (_) => SearchBloc(showRepository: effectiveShowRepo),
          ),
          if (effectiveWatchlistRepo != null)
            BlocProvider<WatchlistBloc>(
              create: (_) => WatchlistBloc(watchlistRepository: effectiveWatchlistRepo)
                ..add(const LoadWatchlist()),
            ),
        ],
        child: MaterialApp.router(
          title: 'TVMaze Explorer',
          theme: AppTheme.darkTheme,
          debugShowCheckedModeBanner: false,
          routerConfig: routerConfig ?? AppRouter.router,
        ),
      ),
    );
  }
}
