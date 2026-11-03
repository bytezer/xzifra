import 'package:flutter_test/flutter_test.dart';
import 'package:xzifra/core/app_shortcut_action.dart';

void main() {
  test('maps shortcut types to routes', () {
    expect(
      AppShortcutAction.fromType('new_expense'),
      AppShortcutAction.newExpense,
    );
    expect(AppShortcutAction.fromType('reports'), AppShortcutAction.reports);
    expect(AppShortcutAction.fromType('unknown'), isNull);

    expect(AppShortcutAction.newExpense.route, '/add');
    expect(AppShortcutAction.reports.route, '/reports');
    expect(AppShortcutAction.newExpense.replacesStack, isFalse);
    expect(AppShortcutAction.reports.replacesStack, isTrue);
  });
}
