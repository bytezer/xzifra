import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n.dart';
import '../../core/widgets/currency_selector.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/month_selector.dart';
import '../../core/widgets/section_card.dart';
import '../../data/database.dart';
import '../../domain/money.dart';
import '../../domain/periods.dart';
import '../../domain/reports.dart';
import '../../providers.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedMonthProvider);
    final currency = ref.watch(selectedCurrencyProvider);
    final start = Periods.startKey(month);
    final end = Periods.endKeyExclusive(month);
    final previous = Periods.addMonths(month, -1);

    final totals =
        ref
            .watch(
              categoryTotalsProvider((
                start: start,
                endExclusive: end,
                currency: currency,
              )),
            )
            .asData
            ?.value ??
        const <CategoryTotal>[];
    final previousTotal = ref
        .watch(
          monthTotalProvider((
            start: Periods.startKey(previous),
            endExclusive: Periods.endKeyExclusive(previous),
            currency: currency,
          )),
        )
        .asData
        ?.value;
    final recent =
        ref.watch(recentExpensesProvider(currency)).asData?.value ??
        const <ExpenseView>[];
    final categories =
        ref.watch(allCategoriesProvider).asData?.value ?? const <Category>[];

    final total = TotalsMath.sum(totals.map((item) => item.totalCents));
    final categoriesById = {for (final item in categories) item.id: item};
    final top = totals.take(5).toList();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          children: [
            const MonthSelector(alignStart: true),
            const SizedBox(height: 8),
            _TotalCard(
              total: total,
              previousTotal: previousTotal,
              currency: currency,
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: context.l10n.dashboardTopCategories,
              child: top.isEmpty
                  ? EmptyState(
                      icon: Icons.donut_large_outlined,
                      title: context.l10n.dashboardNoExpensesTitle,
                      message: context.l10n.dashboardNoExpensesMessage,
                      action: FilledButton.icon(
                        onPressed: () => context.push('/add'),
                        icon: const Icon(Icons.add),
                        label: Text(context.l10n.dashboardAddExpense),
                      ),
                    )
                  : Column(
                      children: [
                        for (final item in top) ...[
                          _CategoryRow(
                            item: item,
                            category: categoriesById[item.categoryId],
                            total: total,
                            currency: currency,
                          ),
                          if (item != top.last) const SizedBox(height: 14),
                        ],
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: context.l10n.dashboardRecentExpenses,
              trailing: recent.isEmpty
                  ? null
                  : TextButton(
                      onPressed: () => context.go('/expenses'),
                      child: Text(context.l10n.dashboardViewAll),
                    ),
              child: recent.isEmpty
                  ? EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: context.l10n.dashboardNothingRecordedTitle,
                      message: context.l10n.dashboardNothingRecordedMessage,
                    )
                  : Column(
                      children: [
                        for (final item in recent) ...[
                          _RecentRow(item: item, currency: currency),
                          if (item != recent.last) const Divider(height: 1),
                        ],
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton.icon(
                            onPressed: () => context.push(
                              '/expenses/${recent.first.expense.id}/duplicate',
                            ),
                            icon: const Icon(Icons.replay_outlined, size: 18),
                            label: Text(context.l10n.dashboardRepeatLast),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({
    required this.total,
    required this.previousTotal,
    required this.currency,
  });

  final int total;
  final int? previousTotal;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.dashboardSpentThisMonth,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const CurrencySelector(),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              Money.format(total, currency, locale: localeNameOf(context)),
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            _DeltaLabel(
              total: total,
              previousTotal: previousTotal,
              currency: currency,
            ),
          ],
        ),
      ),
    );
  }
}

class _DeltaLabel extends StatelessWidget {
  const _DeltaLabel({
    required this.total,
    required this.previousTotal,
    required this.currency,
  });

  final int total;
  final int? previousTotal;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final previous = previousTotal;

    if (previous == null) {
      return Text(
        context.l10n.dashboardLoadingPrevious,
        style: theme.textTheme.bodySmall?.copyWith(
          color: scheme.onPrimaryContainer.withValues(alpha: 0.7),
        ),
      );
    }

    final ratio = TotalsMath.changeRatio(current: total, previous: previous);
    if (ratio == null) {
      return Text(
        context.l10n.dashboardNoSpendingLastMonth,
        style: theme.textTheme.bodySmall?.copyWith(
          color: scheme.onPrimaryContainer.withValues(alpha: 0.7),
        ),
      );
    }

    if (previous == 0 && total == 0) {
      return Text(
        context.l10n.dashboardNoSpendingYet,
        style: theme.textTheme.bodySmall?.copyWith(
          color: scheme.onPrimaryContainer.withValues(alpha: 0.7),
        ),
      );
    }

    if (ratio == 0) {
      return Text(
        context.l10n.dashboardSameAsLastMonth,
        style: theme.textTheme.bodySmall?.copyWith(
          color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
        ),
      );
    }

    final increased = ratio > 0;
    final percent = (ratio.abs() * 100).toStringAsFixed(0);
    return Row(
      children: [
        Icon(
          increased ? Icons.trending_up : Icons.trending_down,
          size: 18,
          color: scheme.onPrimaryContainer,
        ),
        const SizedBox(width: 6),
        Text(
          increased
              ? context.l10n.dashboardIncreased(percent)
              : context.l10n.dashboardDecreased(percent),
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onPrimaryContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.item,
    required this.category,
    required this.total,
    required this.currency,
  });

  final CategoryTotal item;
  final Category? category;
  final int total;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = Color(category?.color ?? 0xFF9E9E9E);
    final share = TotalsMath.share(item.totalCents, total);

    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: color.withValues(alpha: 0.15),
          child: Text(category?.icon ?? '📦'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      category?.name ?? context.l10n.labelUnknownCategory,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    Money.format(
                      item.totalCents,
                      currency,
                      locale: localeNameOf(context),
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: share,
                  minHeight: 6,
                  backgroundColor: color.withValues(alpha: 0.12),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 38,
          child: Text(
            TotalsMath.percent(share),
            textAlign: TextAlign.right,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _RecentRow extends StatelessWidget {
  const _RecentRow({required this.item, required this.currency});

  final ExpenseView item;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final note = item.expense.note?.trim();
    final day = Periods.dayLabel(
      item.expense.date,
      locale: localeNameOf(context),
      today: context.l10n.today,
      yesterday: context.l10n.yesterday,
    );
    final subtitle = note == null || note.isEmpty ? day : '$day · $note';

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => context.push('/expenses/${item.expense.id}/edit'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Color(item.category.color)
                  .withValues(alpha: 0.15),
              child: Text(item.category.icon),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.category.name, style: theme.textTheme.bodyMedium),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              Money.format(
                item.expense.amountCents,
                currency,
                locale: localeNameOf(context),
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
