import 'package:flutter_test/flutter_test.dart';
import 'package:stash_it_app/features/saved_items/presentation/price_label.dart';

/// The pair rules that decide whether the Inbox row shows a price at all.
///
/// The amount is deliberately kept as text: these cases cover the documented
/// formats, exact decimal preservation, and the values that must be hidden
/// rather than shown partially.
void main() {
  group('priceLabel', () {
    test('formats the supported currencies', () {
      expect(priceLabel(amount: '24500000', currency: 'IDR'), 'Rp24.500.000');
      expect(priceLabel(amount: '129.99', currency: 'USD'), 'US\$129.99');
    });

    test('keeps the exact decimal digits instead of using a double', () {
      expect(priceLabel(amount: '0.10', currency: 'USD'), 'US\$0.10');
      expect(
        priceLabel(amount: '12345678901234567890.123', currency: 'USD'),
        'US\$12,345,678,901,234,567,890.123',
      );
    });

    test('accepts a surrounded or lower-case currency code', () {
      expect(priceLabel(amount: '1000', currency: ' idr '), 'Rp1.000');
    });

    test('hides an incomplete pair', () {
      expect(priceLabel(amount: null, currency: 'IDR'), isNull);
      expect(priceLabel(amount: '1000', currency: null), isNull);
      expect(priceLabel(amount: '', currency: 'IDR'), isNull);
      expect(priceLabel(amount: '1000', currency: ''), isNull);
      expect(priceLabel(amount: '  ', currency: 'IDR'), isNull);
    });

    test('hides an unsupported currency', () {
      expect(priceLabel(amount: '1000', currency: 'EUR'), isNull);
    });

    test('hides a malformed amount', () {
      for (final amount in [
        'abc',
        '-5',
        '.5',
        '5.',
        '1e3',
        '12,500',
        '12 500',
        '1.2.3',
      ]) {
        expect(
          priceLabel(amount: amount, currency: 'USD'),
          isNull,
          reason: 'amount "$amount" is not a positive decimal',
        );
      }
    });
  });
}
