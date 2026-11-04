import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/tags.dart';
import '../../data/export_service.dart';
import '../../data/database.dart';
import '../../providers.dart';

class NoteEditorPage extends ConsumerWidget {
  const NoteEditorPage({super.key, this.noteId});

  final String? noteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = noteId;
    if (id == null) {
      return const _NoteForm(initial: null);
    }
    return ref
        .watch(noteByIdProvider(id))
        .when(
          data: (note) => note == null
              ? _NoteLoadError(message: context.l10n.notesNotFound)
              : _NoteForm(initial: note),
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, stackTrace) =>
              _NoteLoadError(message: context.l10n.notesLoadError),
        );
  }
}

class _NoteLoadError extends StatelessWidget {
  const _NoteLoadError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: Text(message)),
    );
  }
}

class _NoteForm extends ConsumerStatefulWidget {
  const _NoteForm({required this.initial});

  final Note? initial;

  @override
  ConsumerState<_NoteForm> createState() => _NoteFormState();
}

class _NoteFormState extends ConsumerState<_NoteForm> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  late final TextEditingController _tagsController;
  late bool _pinned;
  bool _saving = false;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final note = widget.initial;
    _titleController = TextEditingController(text: note?.title ?? '');
    _bodyController = TextEditingController(text: note?.body ?? '');
    _tagsController = TextEditingController(text: note?.tags ?? '');
    _pinned = note?.pinned ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final note = widget.initial;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.notesEditTitle : l10n.notesNewTitle),
        actions: [
          if (note != null)
            PopupMenuButton<_EditorAction>(
              onSelected: _handleAction,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _EditorAction.export,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.ios_share_outlined),
                    title: Text(l10n.notesExportMarkdown),
                  ),
                ),
                PopupMenuItem(
                  value: note.archivedAt == null
                      ? _EditorAction.archive
                      : _EditorAction.unarchive,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      note.archivedAt == null
                          ? Icons.archive_outlined
                          : Icons.unarchive_outlined,
                    ),
                    title: Text(
                      note.archivedAt == null
                          ? l10n.notesArchive
                          : l10n.notesUnarchive,
                    ),
                  ),
                ),
                PopupMenuItem(
                  value: _EditorAction.delete,
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
              labelText: l10n.notesTitleLabel,
              counterText: '',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bodyController,
            minLines: 8,
            maxLines: 20,
            maxLength: 20000,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: l10n.notesBodyLabel,
              hintText: l10n.notesBodyHint,
              alignLabelWithHint: true,
              counterText: '',
            ),
          ),
          const SizedBox(height: 12),
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
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _pinned,
            onChanged: (value) => setState(() => _pinned = value),
            title: Text(l10n.notesPinned),
            secondary: const Icon(Icons.push_pin_outlined),
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

  Future<void> _save() async {
    if (_saving) return;
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      _showMessage(context.l10n.notesTitleError);
      return;
    }
    final body = _bodyController.text.trim();
    final tags = normalizeTags(_tagsController.text);
    final database = ref.read(databaseProvider);
    final note = widget.initial;

    setState(() => _saving = true);
    try {
      if (note == null) {
        await database.addNote(
          title: title,
          body: body,
          tags: tags,
          pinned: _pinned,
        );
      } else {
        await database.updateNote(
          note.id,
          title: title,
          body: body,
          tags: tags,
          pinned: _pinned,
        );
      }
      await HapticFeedback.lightImpact();
      if (!mounted) return;
      context.pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showMessage(context.l10n.notesSaveError);
    }
  }

  Future<void> _handleAction(_EditorAction action) async {
    final note = widget.initial;
    if (note == null) return;
    final database = ref.read(databaseProvider);
    switch (action) {
      case _EditorAction.export:
        try {
          final service = ExportService(database);
          final file = await service.createNoteMarkdown(note);
          await service.shareFile(file, subject: note.title);
        } catch (_) {
          if (mounted) _showMessage(context.l10n.notesExportError);
        }
      case _EditorAction.archive:
        await database.setNoteArchived(note.id, archived: true);
        if (mounted) context.pop();
      case _EditorAction.unarchive:
        await database.setNoteArchived(note.id, archived: false);
        if (mounted) context.pop();
      case _EditorAction.delete:
        final confirmed = await _confirmDelete(note);
        if (!confirmed) return;
        await database.deleteNote(note.id);
        if (mounted) context.pop();
    }
  }

  Future<bool> _confirmDelete(Note note) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.notesDeleteTitle),
        content: Text(context.l10n.notesDeleteMessage(note.title)),
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
    return result ?? false;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

enum _EditorAction { export, archive, unarchive, delete }
