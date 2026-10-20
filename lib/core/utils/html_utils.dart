/// Utility helper to clean and normalize HTML strings returned by TVMaze.
class HtmlUtils {
  HtmlUtils._();

  static final RegExp _blockTagRegex = RegExp(r'<\s*\/?\s*(p|div|br|li|h[1-6]|tr)\b[^>]*>', caseSensitive: false);
  static final RegExp _htmlTagRegex = RegExp(r'<[^>]*>', multiLine: true, caseSensitive: false);

  /// Strips HTML tags and decodes common HTML entities from raw summary strings.
  static String stripHtml(String? htmlString) {
    if (htmlString == null || htmlString.trim().isEmpty) {
      return '';
    }

    // Replace block tags with a space so text between paragraphs is separated
    String cleanText = htmlString.replaceAll(_blockTagRegex, ' ');

    // Strip remaining inline HTML tags
    cleanText = cleanText.replaceAll(_htmlTagRegex, '');

    // Replace common HTML entities
    cleanText = cleanText
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#039;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&ndash;', '–')
        .replaceAll('&mdash;', '—')
        .replaceAll('&hellip;', '...');

    // Collapse multiple consecutive whitespaces/newlines
    cleanText = cleanText.replaceAll(RegExp(r'\s+'), ' ').trim();

    return cleanText;
  }
}
