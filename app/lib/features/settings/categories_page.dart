import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/empty_state.dart';
import '../../data/database.dart';
import '../../providers.dart';

const List<String> _emojis = [
  '🍔',
  '🚌',
  '🏠',
  '💡',
  '🩺',
  '🎬',
  '🛍️',
  '📚',
  '📦',
  '☕',
  '🍺',
  '✈️',
  '🎁',
  '🐾',
  '💻',
  '📱',
  '🏋️',
  '💊',
  '🧾',
  '🚗',
  '⛽',
  '🎓',
  '🧺',
  '🎮',
];

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
      appBar: AppBar(title: const Text('Categories')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          if (all.isEmpty)
            const EmptyState(
              icon: Icons.category_outlined,
              title: 'No categories yet',
              message: 'Add your first category to start recording expenses.',
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
                'Archived',
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
    final database = ref.read(databaseProvider);
    final controller = TextEditingController(text: category?.name ?? '');
    var icon = category?.icon ?? _emojis.first;
    var color = category?.color ?? _palette.first;

    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final theme = Theme.of(context);
            return AlertDialog(
              title: Text(category == null ? 'New category' : 'Edit category'),
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
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Icon', style: theme.textTheme.labelLarge),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        for (final emoji in _emojis)
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
                    Text('Color', style: theme.textTheme.labelLarge),
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
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    final value = controller.text.trim();
                    if (value.isEmpty) return;
                    Navigator.of(dialogContext).pop(value);
                  },
                  child: const Text('Save'),
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
    final count = await database.countExpensesForCategory(category.id);
    if (!context.mounted) return;

    if (count > 0) {
      final archive = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Archive category?'),
          content: Text(
            '"${category.name}" is used by $count '
            '${count == 1 ? 'expense' : 'expenses'}. '
            'Archiving keeps the history intact.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Archive'),
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
        title: const Text('Delete category?'),
        content: Text('Delete "${category.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
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
    return Card(
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: CircleAvatar(
          backgroundColor: Color(category.color).withValues(alpha: 0.15),
          child: Text(category.icon),
        ),
        title: Text(category.name),
        subtitle: archived ? const Text('Archived') : null,
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
            const PopupMenuItem(value: 'edit', child: Text('Edit')),
            if (!archived && onMoveUp != null)
              const PopupMenuItem(value: 'up', child: Text('Move up')),
            if (!archived && onMoveDown != null)
              const PopupMenuItem(value: 'down', child: Text('Move down')),
            if (archived)
              const PopupMenuItem(value: 'restore', child: Text('Restore'))
            else
              const PopupMenuItem(value: 'archive', child: Text('Archive')),
            const PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
        ),
      ),
    );
  }
}
