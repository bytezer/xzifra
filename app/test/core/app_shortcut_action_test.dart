import 'package:flutter_test/flutter_test.dart';
import 'package:xzifra/core/app_shortcut_action.dart';

void main() {
  test('maps shortcut types to routes', () {
    expect(
      AppShortcutAction.fromType('new_expense'),
      AppShortcutAction.newExpense,
    );
    expect(AppShortcutAction.fromType('reports'), AppShortcutAction.reports);
    expect(AppShortcutAction.fromType('new_note'), AppShortcutAction.newNote);
    expect(
      AppShortcutAction.fromType('new_reminder'),
      AppShortcutAction.newReminder,
    );
    expect(AppShortcutAction.fromType('unknown'), isNull);

    expect(AppShortcutAction.newExpense.route, '/add');
    expect(AppShortcutAction.reports.route, '/reports');
    expect(AppShortcutAction.newNote.route, '/notes/new');
    expect(AppShortcutAction.newReminder.route, '/reminders/new');
    expect(AppShortcutAction.newExpense.replacesStack, isFalse);
    expect(AppShortcutAction.reports.replacesStack, isTrue);
    expect(AppShortcutAction.newNote.replacesStack, isFalse);
    expect(AppShortcutAction.newReminder.replacesStack, isFalse);
  });
}
