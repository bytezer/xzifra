import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
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

  test('bookmark ZIP contains unique Markdown files', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await database.select(database.categories).get();
    await database.addBookmark(
      url: 'https://flutter.dev',
      title: 'Flutter',
      note: 'Docs and widgets',
      tags: 'dev, reading',
    );
    await database.addBookmark(
      url: 'https://dart.dev',
      title: 'Flutter',
      note: 'Language guide',
      tags: 'dev',
    );
    final temp = await Directory.systemTemp.createTemp('xzifra-bookmarks-');
    addTearDown(() async {
      if (await temp.exists()) await temp.delete(recursive: true);
    });

    final service = ExportService(
      database,
      temporaryDirectory: () async => temp,
    );
    final bookmarks = await database.select(database.bookmarks).get();
    final zipFile = await service.createBookmarksZip(bookmarks);
    final archive = ZipDecoder().decodeBytes(await zipFile.readAsBytes());

    expect(archive.files.length, 2);
    final names = archive.files.map((file) => file.name).toList();
    expect(names.toSet().length, 2);
    expect(names.every((name) => name.startsWith('Xzifra Bookmarks/')), isTrue);

    final contents = archive.files
        .map((file) => utf8.decode(file.content))
        .toList();
    final flutter = contents.firstWhere(
      (content) => content.contains('https://flutter.dev'),
    );
    expect(flutter, contains('title: "Flutter"'));
    expect(flutter, contains('tags: ["dev", "reading"]'));
    expect(flutter, contains('Docs and widgets'));
    expect(flutter, contains('created:'));
    expect(flutter, contains('updated:'));
    expect(
      contents.any((content) => content.contains('https://dart.dev')),
      isTrue,
    );
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
