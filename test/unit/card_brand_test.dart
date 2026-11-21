import 'package:flutter_test/flutter_test.dart';
import 'package:tagalong/util/card_brand.dart';

void main() {
  group('CardBrand', () {
    test('folds the API ids and the card form display names together', () {
      expect(CardBrand.normalize('visa'), 'visa');
      expect(CardBrand.normalize('Visa'), 'visa');
      expect(CardBrand.normalize('MasterCard'), 'mastercard');
      expect(CardBrand.normalize('American Express'), 'amex');
      expect(CardBrand.normalize('amex'), 'amex');
      expect(CardBrand.normalize('Diners Club'), 'diners');
      expect(CardBrand.normalize(null), '');
    });

    test('labels a card by brand and last four', () {
      expect(CardBrand.label('visa', '4242'), 'Visa •••• 4242');
      expect(CardBrand.label('MasterCard', '4444'), 'Mastercard •••• 4444');
      expect(CardBrand.label('something_new', '0001'), 'Card •••• 0001');
    });

    test('badges fit the 48px badge', () {
      expect(CardBrand.badge('mastercard'), 'MC');
      expect(CardBrand.badge('American Express'), 'AMEX');
      expect(CardBrand.badge(null), 'CARD');
    });

    test('formats expiry as MM/YY', () {
      expect(CardBrand.expiry(4, 2028), '04/28');
      expect(CardBrand.expiry(12, 2030), '12/30');
      expect(CardBrand.expiry(1, 2005), '01/05');
    });
  });
}
