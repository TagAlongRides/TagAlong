import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens for the pastel redesign.
///
/// Every value here comes from the "TagAlong pastel redesign" Figma file
/// (Palette, Color and Dimension variable collections, text and effect
/// styles). Widgets should reach for the semantic names ([TagAlongColors.canvas],
/// [TagAlongColors.toCampus], ...) rather than the raw palette, so a later
/// palette change is a one-file edit.
///
/// Pastels carry meaning, never text on their own: text sits in [ink900] or an
/// 800-shade, and every pairing below is at least 4.5:1.
class TagAlongPalette {
  TagAlongPalette._();

  static const ink900 = Color(0xFF1F1B33);
  static const ink700 = Color(0xFF57536E);
  static const ink500 = Color(0xFF6F6A87);
  static const ink300 = Color(0xFFB9B5C9);
  static const ink100 = Color(0xFFE9E6EF);

  static const cream50 = Color(0xFFFBF8F3);
  static const white = Color(0xFFFFFFFF);

  static const lavender100 = Color(0xFFF1ECFF);
  static const lavender300 = Color(0xFFDCD2FF);
  static const lavender500 = Color(0xFF9F8CF5);
  static const lavender700 = Color(0xFF5B45D6);
  static const lavender800 = Color(0xFF4A35C0);

  static const peach100 = Color(0xFFFFF0E8);
  static const peach300 = Color(0xFFFFD9C7);
  static const peach800 = Color(0xFF9A3D12);

  static const mint100 = Color(0xFFEAF8F0);
  static const mint300 = Color(0xFFC9EEDB);
  static const mint800 = Color(0xFF17643F);

  static const sky100 = Color(0xFFEDF5FF);
  static const sky300 = Color(0xFFCFE6FF);
  static const sky800 = Color(0xFF1B5A8C);

  static const butter100 = Color(0xFFFFF7DD);
  static const butter300 = Color(0xFFFFEBB0);
  static const butter800 = Color(0xFF7A5200);

  static const rose100 = Color(0xFFFFEEF1);
  static const rose300 = Color(0xFFFFD3DA);
  static const rose800 = Color(0xFFA11D2A);
}

/// Semantic colors. These are what screens should use.
class TagAlongColors {
  TagAlongColors._();

  // Backgrounds
  static const canvas = TagAlongPalette.cream50;
  static const surface = TagAlongPalette.white;
  static const subtle = TagAlongPalette.lavender100;
  static const inverse = TagAlongPalette.ink900;

  // Text
  static const textPrimary = TagAlongPalette.ink900;
  static const textSecondary = TagAlongPalette.ink700;
  static const textTertiary = TagAlongPalette.ink500;
  static const textOnInverse = TagAlongPalette.white;
  static const textBrand = TagAlongPalette.lavender800;

  // Borders
  static const border = TagAlongPalette.ink100;
  static const borderStrong = TagAlongPalette.ink300;

  // Brand
  static const brand = TagAlongPalette.lavender700;
  static const brandSoft = TagAlongPalette.lavender300;
  static const brandAccent = TagAlongPalette.lavender500;

  // Direction: peach is to campus, sky is from campus.
  static const toCampus = TagAlongPalette.peach300;
  static const toCampusSoft = TagAlongPalette.peach100;
  static const toCampusInk = TagAlongPalette.peach800;
  static const fromCampus = TagAlongPalette.sky300;
  static const fromCampusSoft = TagAlongPalette.sky100;
  static const fromCampusInk = TagAlongPalette.sky800;

  // Status
  static const success = TagAlongPalette.mint300;
  static const successSoft = TagAlongPalette.mint100;
  static const successInk = TagAlongPalette.mint800;
  static const warning = TagAlongPalette.butter300;
  static const warningInk = TagAlongPalette.butter800;
  static const error = TagAlongPalette.rose300;
  static const errorInk = TagAlongPalette.rose800;

  /// Strong fill for a ride's direction (tags, hero panels, date blocks).
  static Color direction(bool toCampus) => toCampus ? TagAlongColors.toCampus : fromCampus;

  /// Soft fill for a ride's direction (route panels on cards).
  static Color directionSoft(bool toCampus) => toCampus ? toCampusSoft : fromCampusSoft;

  /// Text color that reads on [direction].
  static Color directionInk(bool toCampus) => toCampus ? toCampusInk : fromCampusInk;
}

/// 4-pt spacing scale. Screen gutter is [s6], card padding [s4].
class TagAlongSpace {
  TagAlongSpace._();

  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s8 = 32;
  static const double s10 = 40;

  /// Horizontal padding for a screen's content.
  static const double gutter = s6;
}

/// Corner radii: small chips, inner panels, cards, hero cards and sheets.
class TagAlongRadius {
  TagAlongRadius._();

  static const double sm = 8;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;
  static const double full = 999;

  static BorderRadius get smAll => BorderRadius.circular(sm);
  static BorderRadius get mdAll => BorderRadius.circular(md);
  static BorderRadius get lgAll => BorderRadius.circular(lg);
  static BorderRadius get xlAll => BorderRadius.circular(xl);
  static BorderRadius get pill => BorderRadius.circular(full);
}

/// Ink-tinted, low shadows so white cards lift off the cream canvas without a
/// grey haze.
class TagAlongShadows {
  TagAlongShadows._();

  static Color _ink(double opacity) => TagAlongPalette.ink900.withOpacity(opacity);

  static List<BoxShadow> get level1 => [
        BoxShadow(color: _ink(0.04), offset: const Offset(0, 1), blurRadius: 2),
        BoxShadow(color: _ink(0.05), offset: const Offset(0, 2), blurRadius: 8),
      ];

  static List<BoxShadow> get level2 => [
        BoxShadow(color: _ink(0.05), offset: const Offset(0, 4), blurRadius: 10),
        BoxShadow(color: _ink(0.10), offset: const Offset(0, 12), blurRadius: 28, spreadRadius: -4),
      ];

  static List<BoxShadow> get floating => [
        BoxShadow(color: _ink(0.08), offset: const Offset(0, 8), blurRadius: 16),
        BoxShadow(color: _ink(0.18), offset: const Offset(0, 20), blurRadius: 40, spreadRadius: -8),
      ];
}

/// The 13 text styles. Display and numbers use Bricolage Grotesque for
/// character; everything else uses Plus Jakarta Sans for legibility. There
/// are no light weights.
///
/// [overline] is meant to be shown in capitals; pass the label through
/// `toUpperCase()` (Flutter has no text-case style property).
class TagAlongText {
  TagAlongText._();

  static TextStyle _b(double size, double lineHeight, FontWeight weight, double trackingPercent) {
    return GoogleFonts.bricolageGrotesque(
      fontSize: size,
      height: lineHeight / size,
      fontWeight: weight,
      letterSpacing: size * trackingPercent / 100,
      color: TagAlongColors.textPrimary,
    );
  }

  static TextStyle _j(double size, double lineHeight, FontWeight weight, double trackingPercent) {
    return GoogleFonts.plusJakartaSans(
      fontSize: size,
      height: lineHeight / size,
      fontWeight: weight,
      letterSpacing: size * trackingPercent / 100,
      color: TagAlongColors.textPrimary,
    );
  }

  static final displayLarge = _b(40, 44, FontWeight.w700, -2);
  static final displayMedium = _b(32, 36, FontWeight.w700, -1.5);
  static final titleLarge = _b(24, 30, FontWeight.w600, -1);
  static final titleMedium = _j(18, 24, FontWeight.w700, -0.5);
  static final titleSmall = _j(16, 22, FontWeight.w700, 0);
  static final bodyLarge = _j(16, 24, FontWeight.w500, 0);
  static final bodyMedium = _j(14, 20, FontWeight.w500, 0);
  static final bodySmall = _j(12, 16, FontWeight.w500, 0);
  static final labelLarge = _j(15, 20, FontWeight.w700, 0);
  static final labelMedium = _j(13, 18, FontWeight.w600, 0);
  static final overline = _j(11, 14, FontWeight.w700, 6);
  static final price = _b(22, 26, FontWeight.w700, -1);
  static final hero = _b(44, 48, FontWeight.w700, -2);
}
