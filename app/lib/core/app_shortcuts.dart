import 'package:flutter/material.dart';
import 'package:quick_actions/quick_actions.dart';

import '../l10n/app_localizations.dart';
import '../routing/router.dart';
import 'app_shortcut_action.dart';

/// Registers the launcher shortcuts and routes the action that opened the app.
///
/// Shortcuts are best-effort: on platforms or tests where the plugin is not
/// available, the rest of the app keeps working.
class AppShortcuts {
  AppShortcuts._();

  static const QuickActions _plugin = QuickActions();

  static bool _initialized = false;
  static bool _ready = false;
  static AppShortcutAction? _pending;

  /// Reads the launch action and listens for actions triggered while running.
  ///
  /// Must be called after `WidgetsFlutterBinding.ensureInitialized()` and
  /// before `runApp`.
  static Future<void> initialize() async {
    if (_initialized) return;
    try {
      await _plugin.initialize(_handleAction);
      _initialized = true;
    } catch (_) {
      // Shortcuts are optional; startup must not fail because of them.
    }
  }

  static void _handleAction(String type) {
    final action = AppShortcutAction.fromType(type);
    if (action == null) return;
    if (!_ready) {
      _pending = action;
      return;
    }
    _open(action);
  }

  /// Called once the router has rendered its first frame.
  static void markReady() {
    if (_ready) return;
    _ready = true;
    final action = _pending;
    if (action == null) return;
    _pending = null;
    WidgetsBinding.instance.addPostFrameCallback((_) => _open(action));
  }

  static void _open(AppShortcutAction action) {
    if (action.replacesStack) {
      appRouter.go(action.route);
    } else {
      appRouter.push(action.route);
    }
  }

  /// Updates the long-press labels so they follow the app language.
  static Future<void> updateLabels(AppLocalizations l10n) async {
    if (!_initialized) return;
    try {
      await _plugin.setShortcutItems([
        ShortcutItem(
          type: AppShortcutAction.newExpense.type,
          localizedTitle: l10n.shortcutNewExpense,
        ),
        ShortcutItem(
          type: AppShortcutAction.reports.type,
          localizedTitle: l10n.shortcutReports,
        ),
      ]);
    } catch (_) {
      // Keep whatever shortcut set is already registered.
    }
  }
}
