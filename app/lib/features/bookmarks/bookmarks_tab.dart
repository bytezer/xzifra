import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/tags.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/tag_chips.dart';
import '../../data/database.dart';
import '../../providers.dart';
import 'bookmark_launcher.dart';

class BookmarksTab extends ConsumerStatefulWidget {
  const BookmarksTab({super.key});

  @override
  ConsumerState<BookmarksTab> createState() => _BookmarksTabState();
}

class _BookmarksTabState extends ConsumerState<BookmarksTab> {
  String? _tag;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final all =
        ref.watch(allBookmarksProvider).asData?.value ?? const <Bookmark>[];

    final visible = _tag == null
        ? all
        : all.where((bookmark) => hasTag(bookmark.tags, _tag!)).toList();
    final active = visible
        .where((bookmark) => bookmark.archivedAt == null)
        .toList();
    final archived = visible
        .where((bookmark) => bookmark.archivedAt != null)
        .toList();
    final tags = collectTags(all.map((bookmark) => parseTags(bookmark.tags)));

    return SafeArea(
      top: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TagFilterBar(
              tags: tags,
              selected: _tag,
              onSelected: (value) => setState(() => _tag = value),
            ),
          ),
          Expanded(
            child: all.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: EmptyState(
                        icon: Icons.bookmark_border,
                        title: l10n.bookmarksEmptyTitle,
                        message: l10n.bookmarksEmptyMessage,
                        action: FilledButton.icon(
                          onPressed: () => context.push('/bookmarks/new'),
                          icon: const Icon(Icons.add),
                          label: Text(l10n.dashboardAddBookmark),
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
                      for (final bookmark in active) ...[
                        _BookmarkTile(
                          bookmark: bookmark,
                          onTap: () => openBookmark(context, bookmark.url),
                          onAction: (action) => _handleAction(bookmark, action),
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (archived.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
                          child: Text(
                            l10n.bookmarksArchived,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        for (final bookmark in archived) ...[
                          _BookmarkTile(
                            bookmark: bookmark,
                            onTap: () => openBookmark(context, bookmark.url),
                            onAction: (action) =>
                                _handleAction(bookmark, action),
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

  Future<void> _handleAction(Bookmark bookmark, _BookmarkAction action) async {
    final database = ref.read(databaseProvider);
    switch (action) {
      case _BookmarkAction.edit:
        if (mounted) context.push('/bookmarks/${bookmark.id}/edit');
      case _BookmarkAction.archive:
        await database.setBookmarkArchived(
          bookmark.id,
          archived: bookmark.archivedAt == null,
        );
      case _BookmarkAction.delete:
        final confirmed = await _confirmDelete(bookmark);
        if (!confirmed) return;
        await database.deleteBookmark(bookmark.id);
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.bookmarksDeleted)));
    }
  }

  Future<bool> _confirmDelete(Bookmark bookmark) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.bookmarksDeleteTitle),
        content: Text(
          context.l10n.bookmarksDeleteMessage(bookmarkLabel(bookmark)),
        ),
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
}

enum _BookmarkAction { edit, archive, delete }

class _BookmarkTile extends StatelessWidget {
  const _BookmarkTile({
    required this.bookmark,
    required this.onTap,
    required this.onAction,
  });

  final Bookmark bookmark;
  final VoidCallback onTap;
  final ValueChanged<_BookmarkAction> onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final note = bookmark.note?.trim();
    final tags = parseTags(bookmark.tags);

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
                child: Icon(Icons.bookmark_outline, color: scheme.primary),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bookmarkLabel(bookmark),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      bookmark.url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    if (note != null && note.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        note,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      TagChips(tags: tags),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<_BookmarkAction>(
                tooltip: MaterialLocalizations.of(context).showMenuTooltip,
                onSelected: onAction,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _BookmarkAction.edit,
                    child: Text(context.l10n.actionEdit),
                  ),
                  PopupMenuItem(
                    value: _BookmarkAction.archive,
                    child: Text(
                      bookmark.archivedAt == null
                          ? context.l10n.bookmarksArchive
                          : context.l10n.bookmarksUnarchive,
                    ),
                  ),
                  PopupMenuItem(
                    value: _BookmarkAction.delete,
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
