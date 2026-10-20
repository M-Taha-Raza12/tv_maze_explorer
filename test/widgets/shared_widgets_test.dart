import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tv_maze_application/domain/entities/show.dart';
import 'package:tv_maze_application/shared/widgets/app_empty_state.dart';
import 'package:tv_maze_application/shared/widgets/genre_chip.dart';
import 'package:tv_maze_application/shared/widgets/rating_badge.dart';
import 'package:tv_maze_application/shared/widgets/show_card.dart';

void main() {
  group('Shared Widgets', () {
    testWidgets('RatingBadge displays formatted rating and star icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RatingBadge(rating: 8.5),
          ),
        ),
      );

      expect(find.text('8.5'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    });

    testWidgets('RatingBadge displays N/A when rating is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RatingBadge(rating: null),
          ),
        ),
      );

      expect(find.text('N/A'), findsOneWidget);
    });

    testWidgets('GenreChip renders text label correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GenreChip(label: 'Sci-Fi'),
          ),
        ),
      );

      expect(find.text('Sci-Fi'), findsOneWidget);
    });

    testWidgets('AppEmptyState displays content and triggers action callback', (tester) async {
      bool actionTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppEmptyState(
              title: 'Empty State Title',
              description: 'Empty state description message',
              actionLabel: 'Click Me',
              onAction: () {
                actionTriggered = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Empty State Title'), findsOneWidget);
      expect(find.text('Empty state description message'), findsOneWidget);
      expect(find.text('Click Me'), findsOneWidget);

      await tester.tap(find.text('Click Me'));
      await tester.pump();

      expect(actionTriggered, isTrue);
    });

    testWidgets('ShowCard displays title and extracts premiere year', (tester) async {
      const show = Show(
        id: 1,
        name: 'Dark',
        premiered: '2017-12-01',
        genres: ['Mystery'],
      );

      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ShowCard(
              show: show,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('2017'), findsOneWidget);
      expect(find.text('Mystery'), findsOneWidget);

      await tester.tap(find.byType(ShowCard));
      expect(tapped, isTrue);
    });
  });
}
