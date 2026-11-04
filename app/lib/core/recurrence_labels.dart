import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../domain/recurrence.dart';
import '../l10n/app_localizations.dart';

String frequencyLabel(AppLocalizations l10n, RecurringFrequency frequency) {
  return switch (frequency) {
    RecurringFrequency.daily => l10n.recurringFrequencyDaily,
    RecurringFrequency.weekly => l10n.recurringFrequencyWeekly,
    RecurringFrequency.monthly => l10n.recurringFrequencyMonthly,
    RecurringFrequency.yearly => l10n.recurringFrequencyYearly,
  };
}

String recurrenceDescription(
  AppLocalizations l10n,
  RecurringFrequency frequency,
  int interval,
) {
  final label = frequencyLabel(l10n, frequency);
  if (interval <= 1) return label;
  return l10n.recurringEveryInterval(interval, label);
}

/// Formats a reminder due date and time for lists.
String reminderDueLabel(
  BuildContext context,
  DateTime dueAt, {
  required String today,
  required String yesterday,
}) {
  final now = DateTime.now();
  final todayDate = DateTime(now.year, now.month, now.day);
  final dueDate = DateTime(dueAt.year, dueAt.month, dueAt.day);
  final locale = Localizations.localeOf(context).languageCode;
  final String date;
  if (dueDate == todayDate) {
    date = today;
  } else if (dueDate == todayDate.subtract(const Duration(days: 1))) {
    date = yesterday;
  } else {
    date = DateFormat.MMMEd(locale).format(dueAt);
  }
  return '$date · ${DateFormat.Hm(locale).format(dueAt)}';
}

String reminderFullDateTime(DateTime date, String locale) {
  return DateFormat.yMMMd(locale).add_Hm().format(date);
}

String reminderDateLabel(DateTime date, String locale) {
  return DateFormat.yMMMd(locale).format(date);
}

String reminderTimeLabel(DateTime date, String locale) {
  return DateFormat.Hm(locale).format(date);
}
