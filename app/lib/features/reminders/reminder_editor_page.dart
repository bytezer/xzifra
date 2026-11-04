import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/notifications.dart';
import '../../core/recurrence_labels.dart';
import '../../core/tags.dart';
import '../../data/database.dart';
import '../../domain/attachments.dart';
import '../../providers.dart';
import '../attachments/attachments_section.dart';

class ReminderEditorPage extends ConsumerWidget {
  const ReminderEditorPage({super.key, this.reminderId});

  final String? reminderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = reminderId;
    if (id == null) {
      return const _ReminderForm(initial: null);
    }
    return ref
        .watch(reminderByIdProvider(id))
        .when(
          data: (reminder) => reminder == null
              ? _ReminderLoadError(message: context.l10n.remindersNotFound)
              : _ReminderForm(initial: reminder),
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, stackTrace) =>
              _ReminderLoadError(message: context.l10n.remindersLoadError),
        );
  }
}

class _ReminderLoadError extends StatelessWidget {
  const _ReminderLoadError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: Text(message)),
    );
  }
}

class _ReminderForm extends ConsumerStatefulWidget {
  const _ReminderForm({required this.initial});

  final Reminder? initial;

  @override
  ConsumerState<_ReminderForm> createState() => _ReminderFormState();
}

class _ReminderFormState extends ConsumerState<_ReminderForm> {
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;
  late final TextEditingController _tagsController;
  late DateTime _dueAt;
  bool _saving = false;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final reminder = widget.initial;
    _titleController = TextEditingController(text: reminder?.title ?? '');
    _noteController = TextEditingController(text: reminder?.note ?? '');
    _tagsController = TextEditingController(text: reminder?.tags ?? '');
    _dueAt = reminder?.dueAt ?? DateTime.now().add(const Duration(hours: 1));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = localeNameOf(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? l10n.remindersEditTitle : l10n.remindersNewTitle,
        ),
        actions: [
          if (_isEditing)
            PopupMenuButton<_ReminderEditorAction>(
              onSelected: _handleAction,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _ReminderEditorAction.delete,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.delete_outline,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    title: Text(
                      l10n.actionDelete,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          TextField(
            controller: _titleController,
            autofocus: !_isEditing,
            maxLength: 200,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: l10n.remindersTitleLabel,
              counterText: '',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            minLines: 3,
            maxLines: 8,
            maxLength: 2000,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: l10n.remindersNoteLabel,
              alignLabelWithHint: true,
              counterText: '',
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.remindersDue,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Card(
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    leading: const Icon(Icons.calendar_today_outlined),
                    title: Text(reminderDateLabel(_dueAt, locale)),
                    onTap: _pickDate,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Card(
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    leading: const Icon(Icons.schedule),
                    title: Text(reminderTimeLabel(_dueAt, locale)),
                    onTap: _pickTime,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _tagsController,
            maxLength: 300,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: l10n.tagsLabel,
              hintText: l10n.tagsHint,
              prefixIcon: const Icon(Icons.sell_outlined),
              counterText: '',
            ),
          ),
          const SizedBox(height: 8),
          AttachmentsSection(
            ownerType: AttachmentOwnerType.reminder,
            ownerId: widget.initial?.id,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isEditing ? l10n.expenseSaveChanges : l10n.actionSave),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueAt,
      firstDate: DateTime(2000),
      lastDate: DateTime(DateTime.now().year + 50),
      helpText: context.l10n.remindersDue,
    );
    if (picked == null) return;
    setState(() {
      _dueAt = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _dueAt.hour,
        _dueAt.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dueAt),
      helpText: context.l10n.remindersDue,
    );
    if (picked == null) return;
    setState(() {
      _dueAt = DateTime(
        _dueAt.year,
        _dueAt.month,
        _dueAt.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _showMessage(l10n.remindersTitleError);
      return;
    }
    final note = _noteController.text.trim();
    final tags = normalizeTags(_tagsController.text);
    final database = ref.read(databaseProvider);
    final reminder = widget.initial;
    final isNew = reminder == null;

    setState(() => _saving = true);
    try {
      final existingCount = isNew ? await database.countReminders() : 0;
      final String id;
      if (isNew) {
        id = await database.addReminder(
          title: title,
          note: note.isEmpty ? null : note,
          dueAt: _dueAt,
          tags: tags,
        );
      } else {
        id = reminder.id;
        await database.updateReminder(
          id,
          title: title,
          note: note.isEmpty ? null : note,
          dueAt: _dueAt,
          tags: tags,
        );
      }

      var permissionGranted = true;
      if (isNew && existingCount == 0) {
        permissionGranted = await NotificationService.instance
            .requestPermission();
      }
      final saved = await database.getReminder(id);
      if (saved != null) {
        await NotificationService.instance.scheduleReminder(saved);
      }
      await HapticFeedback.lightImpact();
      if (!mounted) return;
      if (!permissionGranted) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.remindersNotificationsDenied)),
        );
      }
      context.pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showMessage(l10n.remindersSaveError);
    }
  }

  Future<void> _handleAction(_ReminderEditorAction action) async {
    final reminder = widget.initial;
    if (reminder == null) return;
    switch (action) {
      case _ReminderEditorAction.delete:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(context.l10n.remindersDeleteTitle),
            content: Text(context.l10n.remindersDeleteMessage(reminder.title)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(context.l10n.actionCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(context.l10n.actionDelete),
              ),
            ],
          ),
        );
        if (confirmed != true) return;
        await NotificationService.instance.cancelReminder(reminder.id);
        await ref
            .read(attachmentServiceProvider)
            .deleteForOwner(AttachmentOwnerType.reminder, reminder.id);
        await ref.read(databaseProvider).deleteReminder(reminder.id);
        if (mounted) context.pop();
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

enum _ReminderEditorAction { delete }
