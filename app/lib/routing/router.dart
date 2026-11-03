import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/l10n.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/expenses/expense_form_page.dart';
import '../features/expenses/expenses_page.dart';
import '../features/reports/reports_page.dart';
import '../features/settings/about_page.dart';
import '../features/settings/categories_page.dart';
import '../features/settings/payment_methods_page.dart';
import '../features/settings/settings_page.dart';

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
              path: '/expenses',
              builder: (context, state) => const ExpensesPage(),
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
              onPressed: () => context.push('/add'),
              tooltip: l10n.tooltipAddExpense,
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
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: l10n.navExpenses,
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
