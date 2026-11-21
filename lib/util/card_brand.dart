import 'package:flutter/material.dart';
import 'package:tagalong/themes/tagalong_tokens.dart';

/// Display names, badges and colours for card brands.
///
/// Stripe's API sends brands as lower-case ids (`visa`, `mastercard`,
/// `amex`), while the native card form reports display names (`Visa`,
/// `MasterCard`, `American Express`). [normalize] folds both to the API ids.
class CardBrand {
  CardBrand._();

  /// The API id for [brand], whichever form it came in.
  static String normalize(String? brand) {
    final key = (brand ?? '').toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    switch (key) {
      case 'americanexpress':
      case 'amex':
        return 'amex';
      case 'dinersclub':
      case 'diners':
        return 'diners';
      case 'unionpay':
        return 'unionpay';
      default:
        return key;
    }
  }

  /// "Visa", "Mastercard", ... ; "Card" when unknown.
  static String name(String? brand) {
    switch (normalize(brand)) {
      case 'visa':
        return 'Visa';
      case 'mastercard':
        return 'Mastercard';
      case 'amex':
        return 'Amex';
      case 'discover':
        return 'Discover';
      case 'diners':
        return 'Diners Club';
      case 'jcb':
        return 'JCB';
      case 'unionpay':
        return 'UnionPay';
      default:
        return 'Card';
    }
  }

  /// Short text for the brand badge: "VISA", "MC", "AMEX".
  static String badge(String? brand) {
    switch (normalize(brand)) {
      case 'visa':
        return 'VISA';
      case 'mastercard':
        return 'MC';
      case 'amex':
        return 'AMEX';
      case 'discover':
        return 'DISC';
      case 'diners':
        return 'DC';
      case 'jcb':
        return 'JCB';
      case 'unionpay':
        return 'UP';
      default:
        return 'CARD';
    }
  }

  /// Pastel fill behind the badge.
  static Color badgeColor(String? brand) {
    switch (normalize(brand)) {
      case 'visa':
        return TagAlongColors.brandSoft;
      case 'mastercard':
        return TagAlongColors.toCampus;
      case 'amex':
        return TagAlongColors.fromCampus;
      case 'discover':
        return TagAlongColors.warning;
      default:
        return TagAlongColors.success;
    }
  }

  /// "Visa •••• 4242".
  static String label(String? brand, String last4) => '${name(brand)} •••• $last4';

  /// "04/28".
  static String expiry(int month, int year) =>
      '${month.toString().padLeft(2, '0')}/${(year % 100).toString().padLeft(2, '0')}';
}

/// The rounded brand badge shown beside a saved card.
class CardBrandBadge extends StatelessWidget {
  const CardBrandBadge({Key? key, required this.brand, this.width = 48, this.height = 32, this.color})
      : super(key: key);

  final String? brand;
  final double width;
  final double height;

  /// Overrides the brand's colour (the card preview uses white).
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color ?? CardBrand.badgeColor(brand),
        borderRadius: BorderRadius.circular(height <= 20 ? 4 : TagAlongRadius.sm),
      ),
      child: Text(
        CardBrand.badge(brand),
        style: TagAlongText.labelMedium.copyWith(fontSize: height <= 20 ? 8 : 13, fontWeight: FontWeight.w700),
      ),
    );
  }
}
