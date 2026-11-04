import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/tags.dart';
import '../../data/database.dart';
import '../../providers.dart';
import 'bookmark_launcher.dart';

class BookmarkEditorPage extends ConsumerWidget {
  const BookmarkEditorPage({super.key, this.bookmarkId});

  final String? bookmarkId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = bookmarkId;
    if (id == null) {
      return const _BookmarkForm(initial: null);
    }
    return ref
        .watch(bookmarkByIdProvider(id))
        .when(
          data: (bookmark) => bookmark == null
              ? _BookmarkLoadError(message: context.l10n.bookmarksNotFound)
              : _BookmarkForm(initial: bookmark),
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (error, stackTrace) =>
              _BookmarkLoadError(message: context.l10n.bookmarksLoadError),
        );
  }
}

class _BookmarkLoadError extends StatelessWidget {
  const _BookmarkLoadError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: Text(message)),
    );
  }
}

class _BookmarkForm extends ConsumerStatefulWidget {
  const _BookmarkForm({required this.initial});

  final Bookmark? initial;

  @override
  ConsumerState<_BookmarkForm> createState() => _BookmarkFormState();
}

class _BookmarkFormState extends ConsumerState<_BookmarkForm> {
  late final TextEditingController _urlController;
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;
  late final TextEditingController _tagsController;
  bool _saving = false;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    final bookmark = widget.initial;
    _urlController = TextEditingController(text: bookmark?.url ?? '');
    _titleController = TextEditingController(text: bookmark?.title ?? '');
    _noteController = TextEditingController(text: bookmark?.note ?? '');
    _tagsController = TextEditingController(text: bookmark?.tags ?? '');
  }

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? l10n.bookmarksEditTitle : l10n.bookmarksNewTitle,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          TextField(
            controller: _urlController,
            autofocus: !_isEditing,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: l10n.bookmarksUrlLabel,
              hintText: 'https://',
              prefixIcon: const Icon(Icons.link),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _titleController,
            maxLength: 200,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: l10n.bookmarksTitleLabel,
              helperText: l10n.bookmarksTitleHelp,
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
              labelText: l10n.bookmarksNoteLabel,
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
    final url = _urlController.text.trim();
    if (!isValidHttpUrl(url)) {
      _showMessage(context.l10n.bookmarksUrlError);
      return;
    }
    var title = _titleController.text.trim();
    if (title.isEmpty) {
      title = Uri.parse(url).host;
    }
    final note = _noteController.text.trim();
    final tags = normalizeTags(_tagsController.text);
    final database = ref.read(databaseProvider);
    final bookmark = widget.initial;

    setState(() => _saving = true);
    try {
      if (bookmark == null) {
        await database.addBookmark(
          url: url,
          title: title,
          note: note.isEmpty ? null : note,
          tags: tags,
        );
      } else {
        await database.updateBookmark(
          bookmark.id,
          url: url,
          title: title,
          note: note.isEmpty ? null : note,
          tags: tags,
        );
      }
      await HapticFeedback.lightImpact();
      if (!mounted) return;
      context.pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showMessage(context.l10n.bookmarksSaveError);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
