import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xzifra/app.dart';
import 'package:xzifra/data/database.dart';
import 'package:xzifra/domain/periods.dart';
import 'package:xzifra/providers.dart';
import 'package:xzifra/routing/router.dart';

Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 50)),
  );
  await tester.pumpAndSettle();
}

TextField _fieldWithLabel(WidgetTester tester, String label) {
  return tester
      .widgetList<TextField>(find.byType(TextField))
      .firstWhere((field) => field.decoration?.labelText == label);
}

Future<AppDatabase> _pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1080, 1920);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final database = AppDatabase(NativeDatabase.memory());
  addTearDown(database.close);
  await database.select(database.categories).get();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(database)],
      child: const XzifraApp(),
    ),
  );
  await _settle(tester);
  // The router is shared by the whole test process, so return to Home before
  // each scenario.
  appRouter.go('/');
  await _settle(tester);
  return database;
}

void main() {
  testWidgets('quick capture creates a note and the tag filter works', (
    tester,
  ) async {
    final database = await _pumpApp(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await _settle(tester);
    expect(find.text('Expense'), findsOneWidget);
    expect(find.text('Note'), findsOneWidget);
    expect(find.text('Bookmark'), findsOneWidget);

    await tester.tap(find.text('Note'));
    await _settle(tester);
    expect(find.text('New note'), findsOneWidget);

    await tester.enterText(
      find.byWidget(_fieldWithLabel(tester, 'Title')),
      'Trip ideas',
    );
    await tester.enterText(
      find.byWidget(_fieldWithLabel(tester, 'Body')),
      'Visit the coast',
    );
    await tester.enterText(
      find.byWidget(_fieldWithLabel(tester, 'Tags')),
      'travel, personal',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await _settle(tester);

    final notes = await database.select(database.notes).get();
    expect(notes.single.title, 'Trip ideas');
    expect(notes.single.body, 'Visit the coast');
    expect(notes.single.tags, 'travel, personal');

    await tester.tap(find.text('Records'));
    await _settle(tester);
    await tester.tap(find.text('Notes'));
    await _settle(tester);
    expect(find.text('Trip ideas'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'travel'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilterChip, 'personal'));
    await _settle(tester);
    expect(find.text('Trip ideas'), findsOneWidget);

    await tester.tap(find.text('Trip ideas'));
    await _settle(tester);
    expect(find.text('Edit note'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('No files attached.'),
      find.byType(ListView).last,
      const Offset(0, -250),
    );
    await tester.pumpAndSettle();
    expect(find.text('No files attached.'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 20));
  });

  testWidgets('new expense asks to save before attaching files', (
    tester,
  ) async {
    await _pumpApp(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await _settle(tester);
    await tester.tap(find.text('Expense'));
    await _settle(tester);
    expect(find.text('New expense'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('Save first to attach files.'),
      find.byType(ListView).last,
      const Offset(0, -250),
    );
    await tester.pumpAndSettle();
    expect(find.text('Save first to attach files.'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 20));
  });

  testWidgets('quick capture validates and saves a bookmark', (tester) async {
    final database = await _pumpApp(tester);

    await tester.tap(find.byType(FloatingActionButton));
    await _settle(tester);
    await tester.tap(find.text('Bookmark'));
    await _settle(tester);
    expect(find.text('New bookmark'), findsOneWidget);

    await tester.enterText(
      find.byWidget(_fieldWithLabel(tester, 'URL')),
      'not a link',
    );
    await tester.enterText(
      find.byWidget(_fieldWithLabel(tester, 'Title')),
      'Flutter',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await _settle(tester);
    expect(find.text('Enter a valid http or https link.'), findsOneWidget);
    expect(await database.select(database.bookmarks).get(), isEmpty);

    await tester.enterText(
      find.byWidget(_fieldWithLabel(tester, 'URL')),
      'https://flutter.dev',
    );
    await tester.enterText(
      find.byWidget(_fieldWithLabel(tester, 'Tags')),
      'dev, reading',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await _settle(tester);

    final bookmarks = await database.select(database.bookmarks).get();
    expect(bookmarks.single.url, 'https://flutter.dev');
    expect(bookmarks.single.title, 'Flutter');
    expect(bookmarks.single.tags, 'dev, reading');

    await tester.tap(find.text('Records'));
    await _settle(tester);
    await tester.tap(find.text('Bookmarks'));
    await _settle(tester);
    expect(find.text('Flutter'), findsOneWidget);
    expect(find.text('https://flutter.dev'), findsOneWidget);
    expect(find.widgetWithText(FilterChip, 'reading'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 20));
  });

  testWidgets('global search groups expenses, notes and bookmarks', (
    tester,
  ) async {
    final database = await _pumpApp(tester);
    final category = (await database.select(database.categories).get())
        .firstWhere((item) => item.name == 'Food');
    await database.addExpense(
      amountCents: 1250,
      currency: 'PEN',
      date: Periods.dateKey(DateTime.now()),
      categoryId: category.id,
      note: 'Alpha lunch',
    );
    await database.addNote(
      title: 'Alpha note',
      body: 'Remember alpha',
      tags: 'alpha',
    );
    await database.addBookmark(
      url: 'https://alpha.example.com',
      title: 'Alpha site',
      tags: 'alpha',
    );
    await _settle(tester);

    await tester.tap(find.byIcon(Icons.search));
    await _settle(tester);
    expect(
      find.text('Find expenses, notes and bookmarks on this device.'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextField), 'alpha');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await _settle(tester);

    expect(find.text('Alpha note'), findsOneWidget);
    expect(find.text('Alpha site'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Notes'), findsOneWidget);
    expect(find.text('Bookmarks'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 20));
  });

  testWidgets('home shows recent notes and bookmarks cards', (tester) async {
    final database = await _pumpApp(tester);
    await database.addNote(title: 'Home note', body: 'Pinned idea', tags: '');
    await database.addBookmark(
      url: 'https://example.com',
      title: 'Home bookmark',
      tags: '',
    );
    await _settle(tester);

    await tester.dragUntilVisible(
      find.text('Recent notes'),
      find.byType(ListView).first,
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    expect(find.text('Home note'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('Bookmarks'),
      find.byType(ListView).first,
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    expect(find.text('Home bookmark'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 20));
  });
}
