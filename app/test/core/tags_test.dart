import 'package:flutter_test/flutter_test.dart';
import 'package:xzifra/core/tags.dart';

void main() {
  test('parseTags trims, removes empty entries and de-duplicates', () {
    expect(parseTags(' home, work ,, Home, ideas '), ['home', 'work', 'ideas']);
    expect(parseTags(''), isEmpty);
  });

  test('normalizeTags stores a canonical comma-separated list', () {
    expect(normalizeTags('b, a, B'), 'b, a');
  });

  test('collectTags merges lists and sorts case-insensitively', () {
    expect(
      collectTags([
        ['Work', 'home'],
        ['ideas', 'work'],
      ]),
      ['home', 'ideas', 'Work'],
    );
  });

  test('hasTag matches whole tags case-insensitively', () {
    expect(hasTag('home, shopping', 'Shopping'), isTrue);
    expect(hasTag('home, shopping', 'shop'), isFalse);
    expect(hasTag('', 'home'), isFalse);
  });
}
