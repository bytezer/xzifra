/// A launcher shortcut exposed by the app.
///
/// [type] is the stable identifier shared with the `quick_actions` plugin and
/// [route] is the go_router location opened for it.
enum AppShortcutAction {
  newExpense('new_expense', '/add'),
  reports('reports', '/reports'),
  newNote('new_note', '/notes/new'),
  newReminder('new_reminder', '/reminders/new');

  const AppShortcutAction(this.type, this.route);

  final String type;
  final String route;

  /// Reports is a shell branch, so it replaces the current location instead of
  /// stacking a new page on top of it.
  bool get replacesStack => this == AppShortcutAction.reports;

  static AppShortcutAction? fromType(String type) {
    for (final action in values) {
      if (action.type == type) return action;
    }
    return null;
  }
}
