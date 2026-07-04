import 'package:intl/intl.dart';

import '../constants/app_constants.dart';

abstract final class Formatters {
  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'en_AU',
    symbol: '\$',
    decimalDigits: 2,
  );

  static String currency(double amount) => _currency.format(amount);

  static String currencyWithCode(double amount) =>
      '${AppConstants.currencyCode} ${currency(amount)}';

  static String discountPct(double? value) {
    if (value == null) return '';
    return '${value.round()}%';
  }

  static String countdown(DateTime? endsAt) {
    if (endsAt == null) return '';
    final diff = endsAt.difference(DateTime.now());
    if (diff.isNegative) return 'Ended';
    if (diff.inDays > 0) return 'Ends in ${diff.inDays}d ${diff.inHours % 24}h';
    if (diff.inHours > 0) return 'Ends in ${diff.inHours}h ${diff.inMinutes % 60}m';
    return 'Ends in ${diff.inMinutes}m';
  }

  static String dateShort(DateTime date) =>
      DateFormat('d MMM yyyy').format(date);
}
