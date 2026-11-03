import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/money.dart';
import '../../providers.dart';

class CurrencySelector extends ConsumerWidget {
  const CurrencySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currency = ref.watch(selectedCurrencyProvider);
    return SegmentedButton<String>(
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(value: 'PEN', label: Text('PEN')),
        ButtonSegment(value: 'USD', label: Text('USD')),
      ],
      selected: {currency},
      onSelectionChanged: (selection) {
        ref.read(selectedCurrencyProvider.notifier).set(selection.first);
      },
    );
  }
}

class CurrencyLabel extends StatelessWidget {
  const CurrencyLabel({super.key, required this.currency});

  final String currency;

  @override
  Widget build(BuildContext context) {
    return Text(
      '${currency == 'PEN' ? 'Soles' : 'Dollars'} · ${Money.symbolFor(currency)}',
    );
  }
}
