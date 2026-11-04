import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xzifra/data/database.dart';
import 'package:xzifra/data/export_service.dart';
import 'package:xzifra/features/bookmarks/bookmark_launcher.dart';

void main() {
  test('isValidHttpUrl only accepts http and https links', () {
    expect(isValidHttpUrl('https://example.com'), isTrue);
    expect(isValidHttpUrl('http://example.com/path?q=1'), isTrue);
    expect(isValidHttpUrl('example.com'), isFalse);
    expect(isValidHttpUrl('ftp://example.com'), isFalse);
    expect(isValidHttpUrl('https://'), isFalse);
    expect(isValidHttpUrl('not a link'), isFalse);
  });

  test('noteMarkdown writes Obsidian frontmatter and the body', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await database.addNote(
      title: 'Trip "ideas"',
      body: 'Line one\nLine two',
      tags: 'travel, personal',
      pinned: true,
    );
    final note = (await database.select(database.notes).get()).single;
    await database.setNoteArchived(note.id, archived: true);
    final archived = await database.getNote(note.id);

    final markdown = ExportService(database).noteMarkdown(archived!);

    expect(markdown, startsWith('---\n'));
    expect(markdown, contains('title: "Trip \\"ideas\\""'));
    expect(markdown, contains('tags: ["travel", "personal"]'));
    expect(markdown, contains('pinned: true'));
    expect(markdown, contains('archived: true'));
    expect(markdown, contains('# Trip "ideas"'));
    expect(markdown, contains('Line one\nLine two'));
  });
}
