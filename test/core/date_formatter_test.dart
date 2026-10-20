import 'package:flutter_test/flutter_test.dart';
import 'package:tv_maze_application/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter', () {
    test('formatAirDate formats ISO date to readable string', () {
      expect(DateFormatter.formatAirDate('2013-06-24'), 'Jun 24, 2013');
      expect(DateFormatter.formatAirDate(null), 'TBA');
      expect(DateFormatter.formatAirDate(''), 'TBA');
    });

    test('extractYear extracts 4-digit year correctly', () {
      expect(DateFormatter.extractYear('2013-06-24'), '2013');
      expect(DateFormatter.extractYear(null), 'N/A');
      expect(DateFormatter.extractYear(''), 'N/A');
    });

    test('formatRuntime formats minutes into hours and minutes', () {
      expect(DateFormatter.formatRuntime(60), '1h');
      expect(DateFormatter.formatRuntime(90), '1h 30m');
      expect(DateFormatter.formatRuntime(45), '45m');
      expect(DateFormatter.formatRuntime(null), 'N/A');
      expect(DateFormatter.formatRuntime(0), 'N/A');
    });
  });
}
