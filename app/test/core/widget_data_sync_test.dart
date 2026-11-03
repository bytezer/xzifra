import 'package:flutter_test/flutter_test.dart';
import 'package:xzifra/core/widget_data_sync.dart';

void main() {
  group('WidgetDataSync.routeFor', () {
    test('opens the new expense form from xzifra://add', () {
      expect(WidgetDataSync.routeFor(Uri.parse('xzifra://add')), '/add');
    });

    test('opens the dashboard from xzifra://open', () {
      expect(WidgetDataSync.routeFor(Uri.parse('xzifra://open')), '/');
    });

    test('ignores foreign or unknown URIs', () {
      expect(WidgetDataSync.routeFor(Uri.parse('https://example.com')), isNull);
      expect(WidgetDataSync.routeFor(Uri.parse('xzifra://unknown')), isNull);
    });
  });
}
