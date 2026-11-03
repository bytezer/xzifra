import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/periods.dart';
import '../../providers.dart';

class MonthSelector extends ConsumerWidget {
  const MonthSelector({super.key, this.alignStart = false});

  final bool alignStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final notifier = ref.read(selectedMonthProvider.notifier);
    final theme = Theme.of(context);

    return Row(
      children: [
        IconButton(
          onPressed: notifier.previous,
          tooltip: 'Previous month',
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Text(
            Periods.monthLabel(month),
            textAlign: alignStart ? TextAlign.start : TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          onPressed: notifier.canGoNext ? notifier.next : null,
          tooltip: 'Next month',
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}
