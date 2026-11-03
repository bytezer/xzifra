import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/periods.dart';
import '../../providers.dart';
import '../l10n.dart';

class MonthSelector extends ConsumerWidget {
  const MonthSelector({super.key, this.alignStart = false});

  final bool alignStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final notifier = ref.read(selectedMonthProvider.notifier);
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final locale = localeNameOf(context);

    return Row(
      children: [
        IconButton(
          onPressed: notifier.previous,
          tooltip: l10n.tooltipPreviousMonth,
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Text(
            Periods.monthLabel(month, locale: locale),
            textAlign: alignStart ? TextAlign.start : TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        IconButton(
          onPressed: notifier.canGoNext ? notifier.next : null,
          tooltip: l10n.tooltipNextMonth,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}
