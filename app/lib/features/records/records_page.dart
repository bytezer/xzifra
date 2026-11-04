import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../bookmarks/bookmarks_tab.dart';
import '../expenses/expenses_page.dart';
import '../notes/notes_tab.dart';

/// The four-record hub: expenses, notes and bookmarks under one destination.
class RecordsPage extends StatefulWidget {
  const RecordsPage({super.key, this.initialTab = 0});

  /// 0 = expenses, 1 = notes, 2 = bookmarks.
  final int initialTab;

  @override
  State<RecordsPage> createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _controller;

  static const _tabCount = 3;

  @override
  void initState() {
    super.initState();
    _controller = TabController(
      length: _tabCount,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, _tabCount - 1),
    );
  }

  @override
  void didUpdateWidget(covariant RecordsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != oldWidget.initialTab) {
      final index = widget.initialTab.clamp(0, _tabCount - 1);
      if (_controller.index != index) _controller.animateTo(index);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navRecords),
        actions: [
          IconButton(
            onPressed: () => context.push('/search'),
            tooltip: l10n.actionSearch,
            icon: const Icon(Icons.search),
          ),
        ],
        bottom: TabBar(
          controller: _controller,
          tabs: [
            Tab(text: l10n.expensesTitle),
            Tab(text: l10n.notesTitle),
            Tab(text: l10n.bookmarksTitle),
          ],
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: const [ExpensesTab(), NotesTab(), BookmarksTab()],
      ),
    );
  }
}
