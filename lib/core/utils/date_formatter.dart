import 'package:intl/intl.dart';

/// Formatting utilities for dates and airtimes returned by TVMaze.
class DateFormatter {
  DateFormatter._();

  /// Formats an ISO-8601 date string (e.g. `2013-06-24`) to a readable format (e.g. `Jun 24, 2013`).
  static String formatAirDate(String? rawDate) {
    if (rawDate == null || rawDate.trim().isEmpty) {
      return 'TBA';
    }
    try {
      final parsed = DateTime.parse(rawDate);
      return DateFormat('MMM d, y').format(parsed);
    } catch (_) {
      return rawDate;
    }
  }

  /// Extracts the year from a date string (e.g. `2013-06-24` -> `2013`).
  static String extractYear(String? rawDate) {
    if (rawDate == null || rawDate.trim().isEmpty) {
      return 'N/A';
    }
    try {
      final parsed = DateTime.parse(rawDate);
      return parsed.year.toString();
    } catch (_) {
      return rawDate.length >= 4 ? rawDate.substring(0, 4) : rawDate;
    }
  }

  /// Formats runtime in minutes into `1h 30m` or `45m`.
  static String formatRuntime(int? minutes) {
    if (minutes == null || minutes <= 0) {
      return 'N/A';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours > 0 && remainingMinutes > 0) {
      return '${hours}h ${remainingMinutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${remainingMinutes}m';
    }
  }
}
