import 'package:flutter/material.dart';

import '../l10n.dart';

/// Compact, read-only tag chips used in note and bookmark lists.
class TagChips extends StatelessWidget {
  const TagChips({super.key, required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: [
        for (final tag in tags)
          Chip(
            label: Text(tag),
            labelStyle: theme.textTheme.labelSmall,
            padding: EdgeInsets.zero,
            labelPadding: const EdgeInsets.symmetric(horizontal: 6),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            side: BorderSide(color: theme.colorScheme.outlineVariant),
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
      ],
    );
  }
}

/// Horizontal tag filter used by the notes and bookmarks tabs.
class TagFilterBar extends StatelessWidget {
  const TagFilterBar({
    super.key,
    required this.tags,
    required this.selected,
    required this.onSelected,
  });

  final List<String> tags;
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) return const SizedBox.shrink();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
            label: Text(context.l10n.tagsAll),
            selected: selected == null,
            onSelected: (_) => onSelected(null),
          ),
          for (final tag in tags) ...[
            const SizedBox(width: 8),
            FilterChip(
              label: Text(tag),
              selected: selected == tag,
              onSelected: (_) => onSelected(tag),
            ),
          ],
        ],
      ),
    );
  }
}
