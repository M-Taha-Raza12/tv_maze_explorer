import 'package:flutter_test/flutter_test.dart';
import 'package:tv_maze_application/core/utils/html_utils.dart';

void main() {
  group('HtmlUtils', () {
    test('strips standard HTML paragraph and bold tags', () {
      const input = '<p>Under the Dome is the story of a small town.</p><p><b>Barbie</b> is trapped.</p>';
      final result = HtmlUtils.stripHtml(input);
      expect(result, 'Under the Dome is the story of a small town. Barbie is trapped.');
    });

    test('replaces common HTML entities correctly', () {
      const input = 'Rock &amp; Roll &quot;Quotes&quot; and &#039;Apostrophes&#039; &nbsp; spaced';
      final result = HtmlUtils.stripHtml(input);
      expect(result, "Rock & Roll \"Quotes\" and 'Apostrophes' spaced");
    });

    test('handles null and empty input safely', () {
      expect(HtmlUtils.stripHtml(null), '');
      expect(HtmlUtils.stripHtml(''), '');
      expect(HtmlUtils.stripHtml('   '), '');
    });
  });
}
