import '../../core/utils/html_utils.dart';

extension StringExtensions on String? {
  /// Strips HTML tags and unescapes entities.
  String toCleanText() {
    return HtmlUtils.stripHtml(this);
  }

  /// Capitalizes the first letter of string.
  String capitalizeFirst() {
    if (this == null || this!.isEmpty) return '';
    return '${this![0].toUpperCase()}${this!.substring(1)}';
  }
}
