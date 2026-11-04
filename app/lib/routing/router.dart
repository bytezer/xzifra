import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/l10n.dart';
import '../features/bookmarks/bookmark_editor_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/expenses/expense_form_page.dart';
import '../features/notes/note_editor_page.dart';
import '../features/records/quick_capture.dart';
import '../features/records/records_page.dart';
import '../features/recurring/recurring_editor_page.dart';
import '../features/recurring/recurring_page.dart';
import '../features/reminders/reminder_editor_page.dart';
import '../features/reports/reports_page.dart';
import '../features/search/search_page.dart';
import '../features/settings/about_page.dart';
import '../features/settings/categories_page.dart';
import '../features/settings/payment_methods_page.dart';
import '../features/settings/settings_page.dart';
import '../features/templates/templates_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const DashboardPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/records',
              builder: (context, state) => RecordsPage(
                initialTab: _recordsTab(state.uri.queryParameters['tab']),
              ),
            ),
            GoRoute(
              path: '/expenses',
              redirect: (context, state) => '/records',
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/reports',
              builder: (context, state) => const ReportsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsPage(),
              routes: [
                GoRoute(
                  path: 'categories',
                  builder: (context, state) => const CategoriesPage(),
                ),
                GoRoute(
                  path: 'payment-methods',
                  builder: (context, state) => const PaymentMethodsPage(),
                ),
                GoRoute(
                  path: 'templates',
                  builder: (context, state) => const TemplatesPage(),
                ),
                GoRoute(
                  path: 'about',
                  builder: (context, state) => const AboutPage(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/add',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ExpenseFormPage(),
    ),
    GoRoute(
      path: '/search',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SearchPage(),
    ),
    GoRoute(
      path: '/notes/new',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const NoteEditorPage(),
    ),
    GoRoute(
      path: '/notes/:id/edit',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) =>
          NoteEditorPage(noteId: state.pathParameters['id']),
    ),
    GoRoute(
      path: '/bookmarks/new',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const BookmarkEditorPage(),
    ),
    GoRoute(
      path: '/bookmarks/:id/edit',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) =>
          BookmarkEditorPage(bookmarkId: state.pathParameters['id']),
    ),
    GoRoute(
      path: '/recurring',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const RecurringPage(),
    ),
    GoRoute(
      path: '/recurring/new',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const RecurringEditorPage(),
    ),
    GoRoute(
      path: '/recurring/:id/edit',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) =>
          RecurringEditorPage(recurringId: state.pathParameters['id']),
    ),
    GoRoute(
      path: '/reminders/new',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const ReminderEditorPage(),
    ),
    GoRoute(
      path: '/reminders/:id/edit',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) =>
          ReminderEditorPage(reminderId: state.pathParameters['id']),
    ),
    GoRoute(
      path: '/expenses/:id/edit',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) =>
          ExpenseFormPage(expenseId: state.pathParameters['id']),
    ),
    GoRoute(
      path: '/expenses/:id/duplicate',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => ExpenseFormPage(
        expenseId: state.pathParameters['id'],
        duplicate: true,
      ),
    ),
  ],
);

int _recordsTab(String? tab) {
  return switch (tab) {
    'notes' => 1,
    'bookmarks' => 2,
    'reminders' => 3,
    _ => 0,
  };
}

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isSettings = navigationShell.currentIndex == 3;
    return Scaffold(
      body: navigationShell,
      floatingActionButton: isSettings
          ? null
          : FloatingActionButton(
              onPressed: () => showQuickCapture(context),
              tooltip: l10n.tooltipQuickAdd,
              child: const Icon(Icons.add),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.library_books_outlined),
            selectedIcon: const Icon(Icons.library_books),
            label: l10n.navRecords,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: l10n.navReports,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }
}
