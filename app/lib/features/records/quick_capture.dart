import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';

enum QuickCaptureAction { expense, note, bookmark, reminder }

/// Opens the shell's quick capture sheet and navigates to the chosen form.
Future<void> showQuickCapture(BuildContext context) async {
  final l10n = context.l10n;
  final action = await showModalBottomSheet<QuickCaptureAction>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: Text(l10n.quickAddExpense),
            onTap: () => Navigator.of(context).pop(QuickCaptureAction.expense),
          ),
          ListTile(
            leading: const Icon(Icons.note_add_outlined),
            title: Text(l10n.quickAddNote),
            onTap: () => Navigator.of(context).pop(QuickCaptureAction.note),
          ),
          ListTile(
            leading: const Icon(Icons.bookmark_add_outlined),
            title: Text(l10n.quickAddBookmark),
            onTap: () => Navigator.of(context).pop(QuickCaptureAction.bookmark),
          ),
          ListTile(
            leading: const Icon(Icons.notification_add_outlined),
            title: Text(l10n.quickAddReminder),
            onTap: () => Navigator.of(context).pop(QuickCaptureAction.reminder),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  if (action == null || !context.mounted) return;

  switch (action) {
    case QuickCaptureAction.expense:
      context.push('/add');
    case QuickCaptureAction.note:
      context.push('/notes/new');
    case QuickCaptureAction.bookmark:
      context.push('/bookmarks/new');
    case QuickCaptureAction.reminder:
      context.push('/reminders/new');
  }
}
