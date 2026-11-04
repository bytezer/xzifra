import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import '../data/database.dart';
import '../domain/periods.dart';
import '../domain/recurrence.dart';
import '../l10n/app_localizations.dart';
import '../providers.dart';
import '../routing/router.dart';
import 'widget_text.dart';

/// Keeps the Android home-screen widget in sync with the current month and
/// routes taps that launched the app from the widget.
///
/// The plugin is Android-only and unavailable in widget tests, so every call is
/// best-effort: failures must never stop the app from starting or rendering.
class WidgetDataSync extends ConsumerStatefulWidget {
  const WidgetDataSync({super.key, required this.child});

  final Widget child;

  static const String androidName = 'XzifraWidgetProvider';
  static const String monthKey = 'xzifra_widget_month';
  static const String amountKey = 'xzifra_widget_amount';
  static const String emptyMessageKey = 'xzifra_widget_empty';
  static const String nextUpKey = 'xzifra_widget_next_up';

  static const String addUri = 'xzifra://add';
  static const String openUri = 'xzifra://open';

  static StreamSubscription<Uri?>? _subscription;
  static bool _initialized = false;
  static bool _ready = false;
  static Uri? _pending;

  /// Reads the launch URI and listens for widget taps while the app is running.
  ///
  /// Must be called after `WidgetsFlutterBinding.ensureInitialized()` and before
  /// `runApp`.
  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      _subscription ??= HomeWidget.widgetClicked.listen(
        _handleLaunchUri,
        onError: (Object _) {
          // No widget support on this platform; the app still works.
        },
      );
    } on MissingPluginException {
      // Widgets are Android-only.
    } on PlatformException {
      // Keep the app usable if the widget channel is unavailable.
    }

    try {
      _handleLaunchUri(await HomeWidget.initiallyLaunchedFromHomeWidget());
    } on MissingPluginException {
      // Widgets are Android-only.
    } on PlatformException {
      // Keep the app usable if the widget channel is unavailable.
    }
  }

  /// Releases the action that opened the app once the router has rendered.
  static void markReady() {
    if (_ready) return;
    _ready = true;
    final pending = _pending;
    if (pending == null) return;
    _pending = null;
    WidgetsBinding.instance.addPostFrameCallback((_) => _open(pending));
  }

  static void _handleLaunchUri(Uri? uri) {
    if (uri == null || routeFor(uri) == null) return;
    if (!_ready) {
      _pending = uri;
      return;
    }
    _open(uri);
  }

  /// Maps a widget URI to an app route. Returns `null` for foreign URIs.
  static String? routeFor(Uri uri) {
    if (uri.scheme != 'xzifra') return null;
    return switch (uri.host) {
      'add' => '/add',
      'open' => '/',
      _ => null,
    };
  }

  static void _open(Uri uri) {
    final route = routeFor(uri);
    if (route == null) return;
    if (route == '/') {
      appRouter.go(route);
    } else {
      appRouter.push(route);
    }
  }

  /// Writes the widget text and asks the launcher to redraw it.
  static Future<void> push(
    WidgetText text, {
    required String emptyMessage,
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>(monthKey, text.monthLabel);
      await HomeWidget.saveWidgetData<String>(amountKey, text.amountLabel);
      await HomeWidget.saveWidgetData<String>(emptyMessageKey, emptyMessage);
      await HomeWidget.saveWidgetData<String>(nextUpKey, text.nextUpLabel);
      await HomeWidget.updateWidget(androidName: androidName);
    } on MissingPluginException {
      // Widgets are Android-only.
    } on PlatformException {
      // Keep the app usable if the launcher rejects the update.
    }
  }

  @override
  ConsumerState<WidgetDataSync> createState() => _WidgetDataSyncState();
}

class _WidgetDataSyncState extends ConsumerState<WidgetDataSync>
    with WidgetsBindingObserver {
  String? _lastSignature;
  bool _syncScheduled = false;
  AppLocalizations? _l10n;
  String? _localeName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The active locale (and therefore the month and amount formats) changed.
    _l10n = AppLocalizations.of(context);
    _localeName = Localizations.localeOf(context).languageCode;
    _scheduleSync();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _scheduleSync();
  }

  @override
  Widget build(BuildContext context) {
    final currency = ref.watch(defaultCurrencyProvider).asData?.value;
    if (currency != null) {
      final month = _currentMonth();
      // Rebuild (and resync) whenever an expense is added, edited, deleted or
      // imported, because every mutation updates this total.
      ref.watch(
        monthTotalProvider((
          start: Periods.startKey(month),
          endExclusive: Periods.endKeyExclusive(month),
          currency: currency,
        )),
      );
    }
    // Keep the footer in sync with recurring rules and reminders.
    ref.watch(activeRecurringExpensesProvider);
    ref.watch(remindersProvider);
    _scheduleSync();
    return widget.child;
  }

  static DateTime _currentMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void _scheduleSync() {
    if (_syncScheduled) return;
    _syncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncScheduled = false;
      if (mounted) _sync();
    });
  }

  Future<void> _sync() async {
    final currency = ref.read(defaultCurrencyProvider).asData?.value;
    if (currency == null) return;

    final month = _currentMonth();
    final total = ref
        .read(
          monthTotalProvider((
            start: Periods.startKey(month),
            endExclusive: Periods.endKeyExclusive(month),
            currency: currency,
          )),
        )
        .asData
        ?.value;
    // Wait for the first database value; the native widget keeps showing its
    // empty state until then.
    if (total == null) return;

    final l10n = _l10n;
    final locale = _localeName;
    if (l10n == null || locale == null) return;
    final text = WidgetTextFormatter.format(
      month: month,
      totalCents: total,
      currency: currency,
      locale: locale,
      emptyMessage: l10n.widgetEmptyMessage,
      upcoming: _nextUpcoming(),
      nextUpPrefix: l10n.widgetNextUpPrefix,
    );
    final signature = [
      text.monthLabel,
      text.amountLabel,
      text.nextUpLabel,
      l10n.widgetEmptyMessage,
      locale,
    ].join('|');
    if (signature == _lastSignature) return;
    _lastSignature = signature;

    await WidgetDataSync.push(text, emptyMessage: l10n.widgetEmptyMessage);
  }

  WidgetUpcoming? _nextUpcoming() {
    final rules = ref.read(activeRecurringExpensesProvider).asData?.value;
    final reminders = ref.read(remindersProvider).asData?.value;
    if (rules == null || reminders == null) return null;

    RecurringExpense? nextRule;
    DateTime? nextRuleDate;
    for (final rule in rules) {
      final date = parseDateKey(rule.nextDate);
      if (date == null) continue;
      final end = parseDateKey(rule.endDate);
      if (end != null && date.isAfter(end)) continue;
      if (nextRuleDate == null || date.isBefore(nextRuleDate)) {
        nextRule = rule;
        nextRuleDate = date;
      }
    }

    Reminder? nextReminder;
    for (final reminder in reminders) {
      if (reminder.doneAt != null) continue;
      if (nextReminder == null || reminder.dueAt.isBefore(nextReminder.dueAt)) {
        nextReminder = reminder;
      }
    }

    if (nextRule == null && nextReminder == null) return null;
    final ruleWins =
        nextRuleDate != null &&
        (nextReminder == null || !nextRuleDate.isAfter(nextReminder.dueAt));
    if (ruleWins) {
      return WidgetUpcoming(
        title: nextRule!.name,
        date: nextRuleDate,
        amountCents: nextRule.amountCents,
        currency: nextRule.currency,
        isRecurring: true,
      );
    }
    return WidgetUpcoming(title: nextReminder!.title, date: nextReminder.dueAt);
  }
}
