/// Formats a saved item's price for the compact Inbox row.
///
/// Returns null when the amount and currency cannot be shown as a complete,
/// unambiguous price. The caller hides the price section in that case rather
/// than displaying a partial value or a placeholder.
///
/// The amount is handled as text throughout. It is never parsed into a
/// floating-point number, so a value such as `"129.99"` keeps its exact decimal
/// digits. Only the currencies listed in [_formats] are supported; an unknown
/// currency code produces no label.
String? priceLabel({required String? amount, required String? currency}) {
  final code = currency?.trim().toUpperCase();
  final value = amount?.trim();
  if (code == null || code.isEmpty || value == null || value.isEmpty) {
    return null;
  }

  final format = _formats[code];
  if (format == null) return null;

  final match = _amountPattern.firstMatch(value);
  if (match == null) return null;

  final whole = match.group(1)!;
  final fraction = match.group(2);

  return '${format.symbol}'
      '${_groupThousands(whole, format.groupSeparator)}'
      '${fraction == null ? '' : '${format.decimalSeparator}$fraction'}';
}

/// A positive decimal amount with an optional fractional part.
///
/// Signs, exponents, separators and whitespace are rejected: the row only shows
/// a value it can format completely.
final RegExp _amountPattern = RegExp(r'^(\d+)(?:\.(\d+))?$');

/// Formats the digits of the whole part with three-digit grouping.
String _groupThousands(String digits, String separator) {
  final buffer = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) {
      buffer.write(separator);
    }
    buffer.write(digits[index]);
  }
  return buffer.toString();
}

class _CurrencyFormat {
  const _CurrencyFormat(
    this.symbol,
    this.groupSeparator,
    this.decimalSeparator,
  );

  final String symbol;
  final String groupSeparator;
  final String decimalSeparator;
}

/// The currencies this row can display, using their conventional presentation.
const Map<String, _CurrencyFormat> _formats = {
  'IDR': _CurrencyFormat('Rp', '.', ','),
  'USD': _CurrencyFormat('US\$', ',', '.'),
};
