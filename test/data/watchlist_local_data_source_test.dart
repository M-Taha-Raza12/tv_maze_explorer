import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tv_maze_application/data/datasources/watchlist_local_data_source.dart';
import 'package:tv_maze_application/data/models/image_model.dart';
import 'package:tv_maze_application/data/models/rating_model.dart';
import 'package:tv_maze_application/data/models/show_model.dart';

void main() {
  late WatchlistLocalDataSourceImpl dataSource;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    dataSource = WatchlistLocalDataSourceImpl(prefs: prefs);
  });

  const testShow = ShowModel(
    id: 1,
    name: 'Under the Dome',
    rating: RatingModel(average: 6.5),
    image: ImageModel(medium: 'dome_m.jpg', original: 'dome_o.jpg'),
    premiered: '2013-06-24',
    ended: '2015-09-10',
  );

  test('getWatchlist returns empty list when no shows are saved', () async {
    final result = await dataSource.getWatchlist();
    expect(result, isEmpty);
  });

  test('saveShow persists show and isShowInWatchlist returns true', () async {
    await dataSource.saveShow(testShow);

    final list = await dataSource.getWatchlist();
    expect(list.length, 1);
    expect(list.first.id, 1);
    expect(list.first.name, 'Under the Dome');
    expect(list.first.ended, '2015-09-10');

    final exists = await dataSource.isShowInWatchlist(1);
    expect(exists, isTrue);
  });

  test('saveShow prevents duplicate entries when saving the same show repeatedly', () async {
    await dataSource.saveShow(testShow);
    await dataSource.saveShow(testShow);
    await dataSource.saveShow(testShow);

    final list = await dataSource.getWatchlist();
    expect(list.length, 1);
    expect(list.first.id, 1);
  });

  test('removeShow removes show from persisted watchlist by ID', () async {
    await dataSource.saveShow(testShow);
    expect(await dataSource.isShowInWatchlist(1), isTrue);

    await dataSource.removeShow(1);
    final list = await dataSource.getWatchlist();
    expect(list, isEmpty);
    expect(await dataSource.isShowInWatchlist(1), isFalse);
  });
}
