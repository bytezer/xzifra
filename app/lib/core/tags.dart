/// Splits and normalizes the comma-separated tags stored on notes and
/// bookmarks. Tags are case-insensitively de-duplicated while keeping the
/// first spelling the user typed.
List<String> parseTags(String raw) {
  final seen = <String>{};
  final tags = <String>[];
  for (final part in raw.split(',')) {
    final tag = part.trim();
    if (tag.isEmpty) continue;
    if (!seen.add(tag.toLowerCase())) continue;
    tags.add(tag);
  }
  return tags;
}

/// The canonical storage form: `tag one, tag two`.
String normalizeTags(String raw) => parseTags(raw).join(', ');

/// Unique tags across [tagLists], sorted case-insensitively.
List<String> collectTags(Iterable<List<String>> tagLists) {
  final seen = <String>{};
  final tags = <String>[];
  for (final list in tagLists) {
    for (final tag in list) {
      final key = tag.toLowerCase();
      if (seen.add(key)) tags.add(tag);
    }
  }
  tags.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return tags;
}

bool hasTag(String storedTags, String tag) {
  final needle = tag.toLowerCase();
  return parseTags(storedTags).any((item) => item.toLowerCase() == needle);
}
