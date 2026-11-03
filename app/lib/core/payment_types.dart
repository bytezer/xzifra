import '../l10n/app_localizations.dart';

const List<String> paymentTypes = [
  'cash',
  'yape',
  'plin',
  'debit',
  'credit',
  'transfer',
];

String paymentTypeLabel(AppLocalizations l10n, String type) => switch (type) {
  'cash' => l10n.paymentTypeCash,
  'yape' => l10n.paymentTypeYape,
  'plin' => l10n.paymentTypePlin,
  'debit' => l10n.paymentTypeDebit,
  'credit' => l10n.paymentTypeCredit,
  'transfer' => l10n.paymentTypeTransfer,
  _ => type,
};

/// The English seed label, used to hide a redundant type subtitle when the
/// user has not renamed the default payment method.
String paymentTypeEnglishLabel(String type) => switch (type) {
  'cash' => 'Cash',
  'yape' => 'Yape',
  'plin' => 'Plin',
  'debit' => 'Debit card',
  'credit' => 'Credit card',
  'transfer' => 'Bank transfer',
  _ => type,
};
