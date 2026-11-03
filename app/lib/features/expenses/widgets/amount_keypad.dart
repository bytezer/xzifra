import 'package:flutter/material.dart';

class AmountKeypad extends StatelessWidget {
  const AmountKeypad({
    super.key,
    required this.onDigit,
    required this.onDecimal,
    required this.onBackspace,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onDecimal;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _key(context, '1'),
            _key(context, '2'),
            _key(context, '3'),
          ],
        ),
        Row(
          children: [
            _key(context, '4'),
            _key(context, '5'),
            _key(context, '6'),
          ],
        ),
        Row(
          children: [
            _key(context, '7'),
            _key(context, '8'),
            _key(context, '9'),
          ],
        ),
        Row(
          children: [
            _key(context, '.', onTap: onDecimal),
            _key(context, '0'),
            _iconKey(context, Icons.backspace_outlined, onBackspace),
          ],
        ),
      ],
    );
  }

  Widget _key(BuildContext context, String label, {VoidCallback? onTap}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: TextButton(
          onPressed: onTap ?? () => onDigit(label),
          style: _keyStyle(context),
          child: Text(
            label,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _iconKey(BuildContext context, IconData icon, VoidCallback onTap) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: TextButton(
          onPressed: onTap,
          style: _keyStyle(context),
          child: Icon(icon),
        ),
      ),
    );
  }

  ButtonStyle _keyStyle(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextButton.styleFrom(
      backgroundColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
      foregroundColor: scheme.onSurface,
      minimumSize: const Size.fromHeight(54),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
