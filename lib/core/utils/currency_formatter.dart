import 'package:intl/intl.dart';

/// Converts [amountEGP] to [targetCurrency] using [rates] (base: EGP)
/// and returns a locale-aware formatted string with tabular numbers.
String formatCurrency(
  double amountEGP,
  String targetCurrency,
  Map<String, double> rates,
) {
  final rate = rates[targetCurrency] ?? 1.0;
  final converted = amountEGP * rate;
  final formatter = NumberFormat.currency(
    locale: 'en_US',
    symbol: _symbol(targetCurrency),
    decimalDigits: 2,
  );
  return formatter.format(converted);
}

String _symbol(String currency) => switch (currency) {
      'EGP' => 'E£ ',
      'AED' => 'AED ',
      'USD' => r'$ ',
      'EUR' => '€ ',
      'TRY' => '₺ ',
      'SAR' => 'SAR ',
      'GBP' => '£ ',
      _ => '$currency ',
    };
