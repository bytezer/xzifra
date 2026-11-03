import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final month = ref.watch(selectedMonthProvider);
    final currency = ref.watch(selectedCurrencyProvider);

    final start = Periods.startKey(month);
    final end = Periods.endKeyExclusive(month);
    final months = Periods.lastMonths(month, 12);

    final categoryTotals =
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
    final paymentTotals =
        ref
            .watch(
              paymentMethodTotalsProvider((
                start: start,
                endExclusive: end,
                currency: currency,
              )),
            )
            .asData
            ?.value ??
        const <PaymentMethodTotal>[];
    final monthlyTotals =
        ref
            .watch(
              monthlyTotalsProvider((
                start: Periods.startKey(months.first),
                endExclusive: end,
                currency: currency,
              )),
            )
            .asData
            ?.value ??
        const <MonthlyTotal>[];
    final categories =
        ref.watch(allCategoriesProvider).asData?.value ?? const <Category>[];
    final methods =
        ref.watch(allPaymentMethodsProvider).asData?.value ??
        const <PaymentMethod>[];

    final categoriesById = {for (final item in categories) item.id: item};
    final methodsById = {for (final item in methods) item.id: item};
    final total = TotalsMath.sum(categoryTotals.map((item) => item.totalCents));
    final series = TotalsMath.fillMonths(months, monthlyTotals);
    final maxCents = series.fold<int>(
      0,
      (max, item) => math.max(max, item.totalCents),
    );

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.reportsTitle)),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
          children: [
            const MonthSelector(alignStart: true),
            const SizedBox(height: 4),
            const Align(
              alignment: Alignment.centerLeft,
              child: CurrencySelector(),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: context.l10n.reportsByCategory,
              child: categoryTotals.isEmpty
                  ? EmptyState(
                      icon: Icons.pie_chart_outline,
                      title: context.l10n.reportsNoDataTitle,
                      message: context.l10n.reportsNoDataMessage,
                    )
                  : Column(
                      children: [
                        SizedBox(
                          height: 210,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                PieChartData(
                                  sectionsSpace: 2,
                                  centerSpaceRadius: 58,
                                  startDegreeOffset: -90,
                                  sections: [
                                    for (final item in categoryTotals)
                                      PieChartSectionData(
                                        value: item.totalCents.toDouble(),
                                        color: Color(
                                          categoriesById[item.categoryId]
                                                  ?.color ??
                                              0xFF9E9E9E,
                                        ),
                                        radius: 34,
                                        showTitle: false,
                                      ),
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    context.l10n.reportsTotal,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: scheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    Money.format(
                                      total,
                                      currency,
                                      locale: localeNameOf(context),
                                    ),
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        for (final item in categoryTotals) ...[
                          _LegendRow(
                            label:
                                categoriesById[item.categoryId]?.name ??
                                context.l10n.labelUnknownCategory,
                            icon: categoriesById[item.categoryId]?.icon ?? '📦',
                            color: Color(
                              categoriesById[item.categoryId]?.color ??
                                  0xFF9E9E9E,
                            ),
                            amountCents: item.totalCents,
                            share: TotalsMath.share(item.totalCents, total),
                            currency: currency,
                          ),
                          if (item != categoryTotals.last)
                            const SizedBox(height: 10),
                        ],
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: context.l10n.reportsLast12Months,
              child: SizedBox(
                height: 220,
                child: BarChart(
                  BarChartData(
                    maxY: math.max(1000, maxCents * 1.15).toDouble(),
                    alignment: BarChartAlignment.spaceAround,
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (group) => scheme.inverseSurface,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                            BarTooltipItem(
                              Money.format(
                                rod.toY.round(),
                                currency,
                                locale: localeNameOf(context),
                              ),
                              TextStyle(
                                color: scheme.onInverseSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                      ),
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 50,
                          getTitlesWidget: (value, meta) => Text(
                            Money.formatCompact(
                              value.round(),
                              currency,
                              locale: localeNameOf(context),
                            ),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= series.length) {
                              return const SizedBox.shrink();
                            }
                            if (index % 2 != 0 && index != series.length - 1) {
                              return const SizedBox.shrink();
                            }
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                Periods.shortMonthLabel(
                                  months[index],
                                  locale: localeNameOf(context),
                                ),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    barGroups: [
                      for (var i = 0; i < series.length; i++)
                        BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: series[i].totalCents.toDouble(),
                              width: 12,
                              color: scheme.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: context.l10n.reportsByPaymentMethod,
              child: paymentTotals.isEmpty
                  ? EmptyState(
                      icon: Icons.credit_card_outlined,
                      title: context.l10n.reportsNoDataTitle,
                      message: context.l10n.reportsNoPaymentDataMessage,
                    )
                  : Column(
                      children: [
                        for (final item in paymentTotals) ...[
                          _LegendRow(
                            label: item.paymentMethodId == null
                                ? context.l10n.labelNoPaymentMethod
                                : methodsById[item.paymentMethodId]?.name ??
                                      context.l10n.labelUnknownCategory,
                            icon: '💳',
                            color: scheme.primary,
                            amountCents: item.totalCents,
                            share: TotalsMath.share(item.totalCents, total),
                            currency: currency,
                          ),
                          if (item != paymentTotals.last)
                            const SizedBox(height: 10),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.label,
    required this.icon,
    required this.color,
    required this.amountCents,
    required this.share,
    required this.currency,
  });

  final String label;
  final String icon;
  final Color color;
  final int amountCents;
  final double share;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: color.withValues(alpha: 0.15),
          child: Text(icon, style: const TextStyle(fontSize: 14)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    Money.format(
                      amountCents,
                      currency,
                      locale: localeNameOf(context),
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: share,
                  minHeight: 5,
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
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
