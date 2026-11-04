import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/database.dart';
import '../../domain/money.dart';
import '../../providers.dart';
import '../bookmarks/bookmark_launcher.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';
  bool _loading = false;
  List<ExpenseView> _expenses = const [];
  List<Note> _notes = const [];
  List<Bookmark> _bookmarks = const [];
  int _requestId = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final query = _query.trim();
    final hasResults =
        _expenses.isNotEmpty || _notes.isNotEmpty || _bookmarks.isNotEmpty;
    final showEmpty = query.isEmpty;
    final showNoResults = !showEmpty && !_loading && !hasResults;

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: l10n.searchHint,
            border: InputBorder.none,
          ),
          onChanged: _onChanged,
          onSubmitted: (value) {
            _debounce?.cancel();
            _search(value);
          },
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              onPressed: () {
                _debounce?.cancel();
                _controller.clear();
                _search('');
              },
              tooltip: l10n.actionClear,
              icon: const Icon(Icons.close),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : showEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: EmptyState(
                  icon: Icons.search,
                  title: l10n.searchTitle,
                  message: l10n.searchEmptyMessage,
                ),
              ),
            )
          : showNoResults
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: EmptyState(
                  icon: Icons.search_off,
                  title: l10n.searchNoResultsTitle,
                  message: l10n.searchNoResultsMessage,
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                if (_expenses.isNotEmpty) ...[
                  _SectionHeader(
                    icon: Icons.receipt_long_outlined,
                    title: l10n.searchExpenses,
                    count: _expenses.length,
                  ),
                  for (final item in _expenses)
                    _ExpenseResult(
                      item: item,
                      onTap: () =>
                          context.push('/expenses/${item.expense.id}/edit'),
                    ),
                  const SizedBox(height: 12),
                ],
                if (_notes.isNotEmpty) ...[
                  _SectionHeader(
                    icon: Icons.sticky_note_2_outlined,
                    title: l10n.searchNotes,
                    count: _notes.length,
                  ),
                  for (final note in _notes)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        note.pinned
                            ? Icons.push_pin
                            : Icons.sticky_note_2_outlined,
                      ),
                      title: Text(
                        note.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: note.body.trim().isEmpty
                          ? null
                          : Text(
                              note.body.trim(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                      onTap: () => context.push('/notes/${note.id}/edit'),
                    ),
                  const SizedBox(height: 12),
                ],
                if (_bookmarks.isNotEmpty) ...[
                  _SectionHeader(
                    icon: Icons.bookmark_outline,
                    title: l10n.searchBookmarks,
                    count: _bookmarks.length,
                  ),
                  for (final bookmark in _bookmarks)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.bookmark_outline),
                      title: Text(
                        bookmarkLabel(bookmark),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        bookmark.url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.open_in_new, size: 18),
                      onTap: () => openBookmark(context, bookmark.url),
                    ),
                ],
              ],
            ),
    );
  }

  void _onChanged(String value) {
    _query = value;
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      _search('');
      return;
    }
    setState(() {});
    _debounce = Timer(const Duration(milliseconds: 250), () => _search(value));
  }

  Future<void> _search(String value) async {
    final query = value.trim();
    _query = value;
    final request = ++_requestId;
    if (query.isEmpty) {
      setState(() {
        _loading = false;
        _expenses = const [];
        _notes = const [];
        _bookmarks = const [];
      });
      return;
    }

    setState(() {
      _loading = true;
      _expenses = const [];
      _notes = const [];
      _bookmarks = const [];
    });
    final database = ref.read(databaseProvider);
    try {
      final results = await Future.wait([
        database.searchExpenses(query),
        database.searchNotes(query),
        database.searchBookmarks(query),
      ]);
      if (!mounted || request != _requestId) return;
      setState(() {
        _expenses = results[0] as List<ExpenseView>;
        _notes = results[1] as List<Note>;
        _bookmarks = results[2] as List<Bookmark>;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || request != _requestId) return;
      setState(() {
        _expenses = const [];
        _notes = const [];
        _bookmarks = const [];
        _loading = false;
      });
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.count,
  });

  final IconData icon;
  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '$count',
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseResult extends StatelessWidget {
  const _ExpenseResult({required this.item, required this.onTap});

  final ExpenseView item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final note = item.expense.note?.trim();
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: Color(item.category.color).withValues(alpha: 0.15),
        child: Text(item.category.icon),
      ),
      title: Text(item.category.name),
      subtitle: Text(
        note == null || note.isEmpty ? item.expense.date : note,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        Money.format(
          item.expense.amountCents,
          item.expense.currency,
          locale: localeNameOf(context),
        ),
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
