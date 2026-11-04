import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/emoji_palette.dart';
import '../../core/l10n.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/database.dart';
import '../../providers.dart';

const List<int> _palette = [
  0xFFE53935,
  0xFFD81B60,
  0xFF8E24AA,
  0xFF5E35B1,
  0xFF3949AB,
  0xFF1E88E5,
  0xFF00897B,
  0xFF43A047,
  0xFF7CB342,
  0xFFF9A825,
  0xFFFB8C00,
  0xFF6D4C41,
  0xFF546E7A,
];

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final all =
        ref.watch(allCategoriesProvider).asData?.value ?? const <Category>[];
    final active = all.where((item) => item.archivedAt == null).toList();
    final archived = all.where((item) => item.archivedAt != null).toList();
    final database = ref.read(databaseProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.categoriesTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, ref),
        icon: const Icon(Icons.add),
        label: Text(context.l10n.actionAdd),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          if (all.isEmpty)
            EmptyState(
              icon: Icons.category_outlined,
              title: context.l10n.categoriesEmptyTitle,
              message: context.l10n.categoriesEmptyMessage,
            ),
          for (var index = 0; index < active.length; index++) ...[
            _CategoryTile(
              category: active[index],
              onEdit: () => _openEditor(context, ref, category: active[index]),
              onMoveUp: index == 0
                  ? null
                  : () => _move(database, active, index, -1),
              onMoveDown: index == active.length - 1
                  ? null
                  : () => _move(database, active, index, 1),
              onArchive: () => database.setCategoryArchived(
                active[index].id,
                archived: true,
              ),
              onDelete: () => _delete(context, database, active[index]),
            ),
            const SizedBox(height: 8),
          ],
          if (archived.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
              child: Text(
                context.l10n.labelArchived,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            for (final item in archived) ...[
              _CategoryTile(
                category: item,
                archived: true,
                onEdit: () => _openEditor(context, ref, category: item),
                onRestore: () =>
                    database.setCategoryArchived(item.id, archived: false),
                onDelete: () => _delete(context, database, item),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ],
      ),
    );
  }

  Future<void> _move(
    AppDatabase database,
    List<Category> active,
    int index,
    int delta,
  ) async {
    final ids = [for (final item in active) item.id];
    final target = index + delta;
    if (target < 0 || target >= ids.length) return;
    final moved = ids.removeAt(index);
    ids.insert(target, moved);
    await database.reorderCategories(ids);
  }

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, {
    Category? category,
  }) async {
    final l10n = context.l10n;
    final database = ref.read(databaseProvider);
    final controller = TextEditingController(text: category?.name ?? '');
    var icon = category?.icon ?? emojiPalette.first;
    var color = category?.color ?? _palette.first;

    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = Theme.of(context);
            return AlertDialog(
              title: Text(
                category == null
                    ? l10n.categoriesNewTitle
                    : l10n.categoriesEditTitle,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: controller,
                      autofocus: true,
                      maxLength: 40,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: l10n.categoriesName,
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.categoriesIcon,
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        for (final emoji in emojiPalette)
                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => setDialogState(() => icon = emoji),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: icon == emoji
                                    ? scheme.primaryContainer
                                    : null,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                emoji,
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.categoriesColor,
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final value in _palette)
                          InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => setDialogState(() => color = value),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Color(value),
                                shape: BoxShape.circle,
                                border: color == value
                                    ? Border.all(
                                        color: scheme.onSurface,
                                        width: 3,
                                      )
                                    : null,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.actionCancel),
                ),
                FilledButton(
                  onPressed: () {
                    final value = controller.text.trim();
                    if (value.isEmpty) return;
                    Navigator.of(dialogContext).pop(value);
                  },
                  child: Text(l10n.actionSave),
                ),
              ],
            );
          },
        );
      },
    );

    try {
      if (name == null) return;
      if (category == null) {
        await database.addCategory(name: name, icon: icon, color: color);
      } else {
        await database.updateCategory(
          category.id,
          name: name,
          icon: icon,
          color: color,
        );
      }
    } finally {
      controller.dispose();
    }
  }

  Future<void> _delete(
    BuildContext context,
    AppDatabase database,
    Category category,
  ) async {
    final expenseCount = await database.countExpensesForCategory(category.id);
    final templateCount = await database.countTemplatesForCategory(category.id);
    final recurringCount = await database.countRecurringForCategory(
      category.id,
    );
    if (!context.mounted) return;
    final l10n = context.l10n;

    if (expenseCount > 0 || templateCount > 0 || recurringCount > 0) {
      final message = expenseCount > 0
          ? l10n.categoriesArchiveDialogMessage(category.name, expenseCount)
          : templateCount > 0
          ? l10n.categoriesArchiveTemplatesMessage(category.name, templateCount)
          : l10n.categoriesArchiveRecurringMessage(
              category.name,
              recurringCount,
            );
      final archive = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.categoriesArchiveDialogTitle),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.actionCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.actionArchive),
            ),
          ],
        ),
      );
      if (archive == true) {
        await database.setCategoryArchived(category.id, archived: true);
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.categoriesDeleteDialogTitle),
        content: Text(l10n.categoriesDeleteDialogMessage(category.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.actionDelete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await database.deleteCategory(category.id);
    }
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    this.archived = false,
    this.onEdit,
    this.onMoveUp,
    this.onMoveDown,
    this.onArchive,
    this.onRestore,
    this.onDelete,
  });

  final Category category;
  final bool archived;
  final VoidCallback? onEdit;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  final VoidCallback? onArchive;
  final VoidCallback? onRestore;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: CircleAvatar(
          backgroundColor: Color(category.color).withValues(alpha: 0.15),
          child: Text(category.icon),
        ),
        title: Text(category.name),
        subtitle: archived ? Text(l10n.categoryArchived) : null,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                onEdit?.call();
              case 'up':
                onMoveUp?.call();
              case 'down':
                onMoveDown?.call();
              case 'archive':
                onArchive?.call();
              case 'restore':
                onRestore?.call();
              case 'delete':
                onDelete?.call();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(value: 'edit', child: Text(l10n.actionEdit)),
            if (!archived && onMoveUp != null)
              PopupMenuItem(value: 'up', child: Text(l10n.actionMoveUp)),
            if (!archived && onMoveDown != null)
              PopupMenuItem(value: 'down', child: Text(l10n.actionMoveDown)),
            if (archived)
              PopupMenuItem(value: 'restore', child: Text(l10n.actionRestore))
            else
              PopupMenuItem(value: 'archive', child: Text(l10n.actionArchive)),
            PopupMenuItem(value: 'delete', child: Text(l10n.actionDelete)),
          ],
        ),
      ),
    );
  }
}
