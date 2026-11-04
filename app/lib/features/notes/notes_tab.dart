import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/tags.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/tag_chips.dart';
import '../../data/database.dart';
import '../../data/export_service.dart';
import '../../domain/attachments.dart';
import '../../providers.dart';

class NotesTab extends ConsumerStatefulWidget {
  const NotesTab({super.key});

  @override
  ConsumerState<NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends ConsumerState<NotesTab> {
  String? _tag;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final allNotes =
        ref.watch(allNotesProvider).asData?.value ?? const <Note>[];

    final visible = _tag == null
        ? allNotes
        : allNotes.where((note) => hasTag(note.tags, _tag!)).toList();
    final active = visible.where((note) => note.archivedAt == null).toList();
    final archived = visible.where((note) => note.archivedAt != null).toList();
    final tags = collectTags(allNotes.map((note) => parseTags(note.tags)));
    final attachmentCounts =
        ref
            .watch(attachmentCountsProvider(AttachmentOwnerType.note))
            .asData
            ?.value ??
        const <String, int>{};

    return SafeArea(
      top: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: TagFilterBar(
                    tags: tags,
                    selected: _tag,
                    onSelected: (value) => setState(() => _tag = value),
                  ),
                ),
                IconButton(
                  onPressed: allNotes.isEmpty ? null : _exportAll,
                  tooltip: l10n.notesExportAll,
                  icon: const Icon(Icons.folder_zip_outlined),
                ),
              ],
            ),
          ),
          Expanded(
            child: allNotes.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: EmptyState(
                        icon: Icons.sticky_note_2_outlined,
                        title: l10n.notesEmptyTitle,
                        message: l10n.notesEmptyMessage,
                        action: FilledButton.icon(
                          onPressed: () => context.push('/notes/new'),
                          icon: const Icon(Icons.add),
                          label: Text(l10n.dashboardAddNote),
                        ),
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                    children: [
                      if (active.isEmpty && archived.isEmpty)
                        EmptyState(
                          icon: Icons.filter_alt_off_outlined,
                          title: l10n.notesNoMatchesTitle,
                          message: l10n.notesNoMatchesMessage,
                        ),
                      for (final note in active) ...[
                        _NoteTile(
                          note: note,
                          attachmentCount: attachmentCounts[note.id] ?? 0,
                          onTap: () => context.push('/notes/${note.id}/edit'),
                          onAction: (action) => _handleAction(note, action),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (archived.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                          child: Text(
                            l10n.notesArchived,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        for (final note in archived) ...[
                          _NoteTile(
                            note: note,
                            attachmentCount: attachmentCounts[note.id] ?? 0,
                            onTap: () => context.push('/notes/${note.id}/edit'),
                            onAction: (action) => _handleAction(note, action),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleAction(Note note, _NoteAction action) async {
    final database = ref.read(databaseProvider);
    switch (action) {
      case _NoteAction.pin:
        await database.setNotePinned(note.id, pinned: !note.pinned);
      case _NoteAction.export:
        try {
          final service = ExportService(database);
          final file = await service.createNoteMarkdown(note);
          await service.shareFile(file, subject: note.title);
        } catch (_) {
          if (!mounted) return;
          _showMessage(context.l10n.notesExportError);
        }
      case _NoteAction.archive:
        await database.setNoteArchived(
          note.id,
          archived: note.archivedAt == null,
        );
      case _NoteAction.delete:
        final confirmed = await _confirmDelete(note);
        if (!confirmed) return;
        await ref
            .read(attachmentServiceProvider)
            .deleteForOwner(AttachmentOwnerType.note, note.id);
        await database.deleteNote(note.id);
        if (!mounted) return;
        _showMessage(context.l10n.notesDeleted);
    }
  }

  Future<void> _exportAll() async {
    final notes = ref.read(allNotesProvider).asData?.value ?? const <Note>[];
    if (notes.isEmpty) return;
    final subject = context.l10n.notesExportAll;
    try {
      final service = ExportService(ref.read(databaseProvider));
      final file = await service.createNotesZip(notes);
      await service.shareFile(file, subject: subject);
    } catch (_) {
      if (!mounted) return;
      _showMessage(context.l10n.notesExportAllError);
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

enum _NoteAction { pin, export, archive, delete }

class _NoteTile extends StatelessWidget {
  const _NoteTile({
    required this.note,
    required this.attachmentCount,
    required this.onTap,
    required this.onAction,
  });

  final Note note;
  final int attachmentCount;
  final VoidCallback onTap;
  final ValueChanged<_NoteAction> onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final body = note.body.trim();
    final tags = parseTags(note.tags);

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2, right: 10),
                child: Icon(
                  note.pinned ? Icons.push_pin : Icons.sticky_note_2_outlined,
                  color: note.pinned ? scheme.primary : scheme.outline,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (body.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      TagChips(tags: tags),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<_NoteAction>(
                tooltip: MaterialLocalizations.of(context).showMenuTooltip,
                onSelected: onAction,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _NoteAction.pin,
                    child: Text(
                      note.pinned
                          ? context.l10n.notesUnpin
                          : context.l10n.notesPin,
                    ),
                  ),
                  PopupMenuItem(
                    value: _NoteAction.export,
                    child: Text(context.l10n.notesExportMarkdown),
                  ),
                  PopupMenuItem(
                    value: _NoteAction.archive,
                    child: Text(
                      note.archivedAt == null
                          ? context.l10n.notesArchive
                          : context.l10n.notesUnarchive,
                    ),
                  ),
                  PopupMenuItem(
                    value: _NoteAction.delete,
                    child: Text(
                      context.l10n.actionDelete,
                      style: TextStyle(color: scheme.error),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
