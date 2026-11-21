import 'package:flutter/material.dart';
import 'package:tagalong/themes/tagalong_tokens.dart';

export 'package:tagalong/themes/tagalong_tokens.dart';

/// The app-wide Material 3 theme for the pastel redesign.
///
/// Cream canvas, white cards, deep-ink text and one ink call to action per
/// screen; pastel fills carry meaning (direction, status, role). The raw
/// values live in `tagalong_tokens.dart`.
///
/// The older static members ([primarySwatch], [colorHighEmphasis],
/// [lightTextTheme], the button themes, ...) are kept, remapped onto the new
/// tokens, because screens that have not been rebuilt yet still read them
/// directly. New code should use [TagAlongColors] and [TagAlongText].
class TagAlongTheme {
  TagAlongTheme._();

  // ---------------------------------------------------------------------------
  // Legacy colour names, remapped
  // ---------------------------------------------------------------------------

  /// Lavender ramp; 500 is the brand colour.
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF5B45D6,
    <int, Color>{
      50: TagAlongPalette.lavender100,
      100: TagAlongPalette.lavender100,
      200: TagAlongPalette.lavender300,
      300: TagAlongPalette.lavender300,
      400: TagAlongPalette.lavender500,
      500: TagAlongPalette.lavender700,
      600: TagAlongPalette.lavender700,
      700: TagAlongPalette.lavender800,
      800: TagAlongPalette.lavender800,
      900: TagAlongPalette.ink900,
    },
  );

  /// Warm neutrals; 50 is the canvas.
  static const MaterialColor secondarySwatch = MaterialColor(
    0xFFFFD9C7,
    <int, Color>{
      50: TagAlongPalette.cream50,
      100: TagAlongPalette.peach100,
      200: TagAlongPalette.lavender100,
      300: TagAlongPalette.peach300,
      400: TagAlongPalette.peach300,
      500: TagAlongPalette.peach300,
      600: TagAlongPalette.peach300,
      700: TagAlongPalette.peach800,
      800: TagAlongPalette.peach800,
      900: TagAlongPalette.peach800,
    },
  );

  static const Color colorHighEmphasis = TagAlongColors.textPrimary;
  static const Color colorMediumEmphasis = TagAlongColors.textTertiary;
  static const Color colorDisabled = TagAlongColors.borderStrong;

  /// A soft error fill (banners, cancelled notices). Put [TagAlongColors.errorInk]
  /// text on it.
  static const Color colorError = TagAlongColors.error;

  // ---------------------------------------------------------------------------
  // Text
  // ---------------------------------------------------------------------------

  /// Material's text roles mapped onto the redesign's 13-style scale. The old
  /// sizes were one step larger across the board (and light-weight), so each
  /// role lands on the nearest new style rather than its literal name.
  static TextTheme lightTextTheme = TextTheme(
    displayLarge: TagAlongText.hero,
    displayMedium: TagAlongText.displayLarge,
    displaySmall: TagAlongText.displayMedium,
    headlineLarge: TagAlongText.displayMedium,
    headlineMedium: TagAlongText.displayMedium,
    headlineSmall: TagAlongText.titleLarge,
    titleLarge: TagAlongText.titleMedium,
    titleMedium: TagAlongText.titleSmall,
    titleSmall: TagAlongText.labelMedium,
    bodyLarge: TagAlongText.bodyLarge,
    bodyMedium: TagAlongText.bodyMedium,
    bodySmall: TagAlongText.bodySmall.copyWith(color: TagAlongColors.textSecondary),
    labelLarge: TagAlongText.labelLarge,
    labelMedium: TagAlongText.labelMedium,
    labelSmall: TagAlongText.overline.copyWith(color: TagAlongColors.textSecondary),
  );

  // ---------------------------------------------------------------------------
  // Colour scheme
  // ---------------------------------------------------------------------------

  static const ColorScheme colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: TagAlongColors.brand,
    onPrimary: TagAlongColors.textOnInverse,
    primaryContainer: TagAlongColors.brandSoft,
    onPrimaryContainer: TagAlongColors.textPrimary,
    secondary: TagAlongColors.inverse,
    onSecondary: TagAlongColors.textOnInverse,
    secondaryContainer: TagAlongColors.brandSoft,
    onSecondaryContainer: TagAlongColors.textPrimary,
    tertiary: TagAlongColors.toCampus,
    onTertiary: TagAlongColors.textPrimary,
    tertiaryContainer: TagAlongColors.toCampusSoft,
    onTertiaryContainer: TagAlongColors.toCampusInk,
    error: TagAlongColors.errorInk,
    onError: TagAlongColors.textOnInverse,
    errorContainer: TagAlongColors.error,
    onErrorContainer: TagAlongColors.errorInk,
    surface: TagAlongColors.surface,
    onSurface: TagAlongColors.textPrimary,
    onSurfaceVariant: TagAlongColors.textSecondary,
    surfaceContainerLowest: TagAlongColors.surface,
    surfaceContainerLow: TagAlongColors.canvas,
    surfaceContainer: TagAlongColors.surface,
    surfaceContainerHigh: TagAlongColors.subtle,
    surfaceContainerHighest: TagAlongColors.subtle,
    outline: TagAlongColors.borderStrong,
    outlineVariant: TagAlongColors.border,
    inverseSurface: TagAlongColors.inverse,
    onInverseSurface: TagAlongColors.textOnInverse,
    inversePrimary: TagAlongColors.brandSoft,
    shadow: TagAlongPalette.ink900,
    scrim: TagAlongPalette.ink900,
    surfaceTint: Colors.transparent,
  );

  // ---------------------------------------------------------------------------
  // Component themes
  // ---------------------------------------------------------------------------

  static RoundedRectangleBorder get _pill => RoundedRectangleBorder(borderRadius: TagAlongRadius.pill);

  static final AppBarTheme appBarTheme = AppBarTheme(
    backgroundColor: TagAlongColors.canvas,
    foregroundColor: TagAlongColors.textPrimary,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: true,
    titleTextStyle: TagAlongText.titleSmall,
    iconTheme: const IconThemeData(color: TagAlongColors.textPrimary),
  );

  static const AppBarTheme progressBarTheme = AppBarTheme(
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(
      color: TagAlongColors.textPrimary,
      size: 18,
    ),
    elevation: 0,
    scrolledUnderElevation: 0,
  );

  /// The primary button: ink fill, white label, pill, 52 tall. One per screen.
  static final ElevatedButtonThemeData elevatedButtonTheme = ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled) ? TagAlongColors.border : TagAlongColors.inverse,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled) ? TagAlongColors.textTertiary : TagAlongColors.textOnInverse,
      ),
      overlayColor: WidgetStatePropertyAll(Colors.white.withOpacity(0.08)),
      elevation: const WidgetStatePropertyAll(0),
      textStyle: WidgetStatePropertyAll(TagAlongText.labelLarge),
      minimumSize: const WidgetStatePropertyAll(Size(64, 52)),
      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: TagAlongSpace.s6)),
      shape: WidgetStatePropertyAll(_pill),
    ),
  );

  /// The soft secondary button: lavender 300 fill, ink label.
  static final FilledButtonThemeData filledButtonTheme = FilledButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled) ? TagAlongColors.border : TagAlongColors.brandSoft,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled) ? TagAlongColors.textTertiary : TagAlongColors.textPrimary,
      ),
      elevation: const WidgetStatePropertyAll(0),
      textStyle: WidgetStatePropertyAll(TagAlongText.labelLarge),
      minimumSize: const WidgetStatePropertyAll(Size(64, 52)),
      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: TagAlongSpace.s6)),
      shape: WidgetStatePropertyAll(_pill),
    ),
  );

  /// The tertiary button: 1.5px strong border, ink label.
  static final OutlinedButtonThemeData outlinedButtonTheme = OutlinedButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled) ? TagAlongColors.textTertiary : TagAlongColors.textPrimary,
      ),
      textStyle: WidgetStatePropertyAll(TagAlongText.labelLarge),
      minimumSize: const WidgetStatePropertyAll(Size(64, 40)),
      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: TagAlongSpace.s5)),
      side: WidgetStateProperty.resolveWith(
        (states) => BorderSide(
          color: states.contains(WidgetState.disabled) ? TagAlongColors.border : TagAlongColors.borderStrong,
          width: 1.5,
        ),
      ),
      shape: WidgetStatePropertyAll(_pill),
    ),
  );

  static final TextButtonThemeData textButtonTheme = TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled) ? TagAlongColors.textTertiary : TagAlongColors.textBrand,
      ),
      backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
      textStyle: WidgetStatePropertyAll(TagAlongText.labelMedium.copyWith(fontWeight: FontWeight.w700)),
      shape: WidgetStatePropertyAll(_pill),
    ),
  );

  static const FloatingActionButtonThemeData floatingActionButtonTheme = FloatingActionButtonThemeData(
    foregroundColor: TagAlongColors.textPrimary,
    backgroundColor: TagAlongColors.toCampus,
    elevation: 0,
    shape: StadiumBorder(),
  );

  /// Filter chips: white with a light border, ink when selected.
  static final ChipThemeData chipTheme = ChipThemeData(
    backgroundColor: TagAlongColors.surface,
    selectedColor: TagAlongColors.inverse,
    disabledColor: TagAlongColors.border,
    checkmarkColor: TagAlongColors.textOnInverse,
    showCheckmark: false,
    padding: const EdgeInsets.symmetric(horizontal: TagAlongSpace.s2, vertical: TagAlongSpace.s2),
    labelStyle: TagAlongText.labelMedium.copyWith(
      color: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.selected) ? TagAlongColors.textOnInverse : TagAlongColors.textPrimary,
      ),
    ),
    iconTheme: const IconThemeData(size: 18),
    side: WidgetStateBorderSide.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? const BorderSide(color: TagAlongColors.inverse, width: 1.5)
          : const BorderSide(color: TagAlongColors.border, width: 1.5),
    ),
    shape: _pill,
    brightness: Brightness.light,
  );

  /// Filled field with a floating label; 2px lavender ring on focus.
  static final InputDecorationTheme inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: TagAlongColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: TagAlongSpace.s4, vertical: TagAlongSpace.s3),
    labelStyle: TagAlongText.bodyMedium.copyWith(color: TagAlongColors.textTertiary),
    floatingLabelStyle: TagAlongText.bodySmall.copyWith(color: TagAlongColors.textTertiary),
    hintStyle: TagAlongText.bodyLarge.copyWith(color: TagAlongColors.textTertiary),
    helperStyle: TagAlongText.bodySmall.copyWith(color: TagAlongColors.textTertiary),
    errorStyle: TagAlongText.bodySmall.copyWith(color: TagAlongColors.errorInk),
    prefixIconColor: TagAlongColors.textSecondary,
    suffixIconColor: TagAlongColors.textSecondary,
    border: OutlineInputBorder(
      borderRadius: TagAlongRadius.mdAll,
      borderSide: const BorderSide(color: TagAlongColors.border, width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: TagAlongRadius.mdAll,
      borderSide: const BorderSide(color: TagAlongColors.border, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: TagAlongRadius.mdAll,
      borderSide: const BorderSide(color: TagAlongColors.brand, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: TagAlongRadius.mdAll,
      borderSide: const BorderSide(color: TagAlongColors.errorInk, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: TagAlongRadius.mdAll,
      borderSide: const BorderSide(color: TagAlongColors.errorInk, width: 2),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: TagAlongRadius.mdAll,
      borderSide: const BorderSide(color: TagAlongColors.border, width: 1.5),
    ),
  );

  static final DialogThemeData dialogTheme = DialogThemeData(
    backgroundColor: TagAlongColors.surface,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: TagAlongRadius.xlAll),
    titleTextStyle: TagAlongText.titleLarge,
    contentTextStyle: TagAlongText.bodyMedium.copyWith(color: TagAlongColors.textSecondary),
  );

  static const BottomSheetThemeData bottomSheetTheme = BottomSheetThemeData(
    backgroundColor: TagAlongColors.canvas,
    surfaceTintColor: Colors.transparent,
    showDragHandle: true,
    dragHandleColor: TagAlongColors.borderStrong,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(TagAlongRadius.xl)),
    ),
  );

  static final SnackBarThemeData snackBarTheme = SnackBarThemeData(
    backgroundColor: TagAlongColors.inverse,
    contentTextStyle: TagAlongText.bodyMedium.copyWith(color: TagAlongColors.textOnInverse),
    actionTextColor: TagAlongColors.brandSoft,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: TagAlongRadius.mdAll),
  );

  static final CardThemeData cardTheme = CardThemeData(
    color: TagAlongColors.surface,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(borderRadius: TagAlongRadius.lgAll),
  );

  static final ListTileThemeData listTileTheme = ListTileThemeData(
    iconColor: TagAlongColors.textPrimary,
    textColor: TagAlongColors.textPrimary,
    titleTextStyle: TagAlongText.titleSmall,
    subtitleTextStyle: TagAlongText.bodySmall.copyWith(color: TagAlongColors.textTertiary),
    shape: RoundedRectangleBorder(borderRadius: TagAlongRadius.lgAll),
  );

  static final TimePickerThemeData timePickerTheme = TimePickerThemeData(
    backgroundColor: TagAlongColors.surface,
    shape: RoundedRectangleBorder(borderRadius: TagAlongRadius.xlAll),
    dayPeriodColor: TagAlongColors.brandSoft,
    hourMinuteColor: TagAlongColors.subtle,
    dialBackgroundColor: TagAlongColors.subtle,
  );

  static final DatePickerThemeData datePickerTheme = DatePickerThemeData(
    backgroundColor: TagAlongColors.surface,
    surfaceTintColor: Colors.transparent,
    headerBackgroundColor: TagAlongColors.canvas,
    headerForegroundColor: TagAlongColors.textPrimary,
    rangeSelectionBackgroundColor: TagAlongColors.subtle,
    shape: RoundedRectangleBorder(borderRadius: TagAlongRadius.xlAll),
  );

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: TagAlongColors.canvas,
      canvasColor: TagAlongColors.canvas,
      dividerColor: TagAlongColors.border,
      fontFamily: TagAlongText.bodyMedium.fontFamily,
      textTheme: lightTextTheme,
      iconTheme: const IconThemeData(color: TagAlongColors.textPrimary),
      appBarTheme: appBarTheme,
      floatingActionButtonTheme: floatingActionButtonTheme,
      elevatedButtonTheme: elevatedButtonTheme,
      filledButtonTheme: filledButtonTheme,
      outlinedButtonTheme: outlinedButtonTheme,
      textButtonTheme: textButtonTheme,
      chipTheme: chipTheme,
      inputDecorationTheme: inputDecorationTheme,
      dialogTheme: dialogTheme,
      bottomSheetTheme: bottomSheetTheme,
      snackBarTheme: snackBarTheme,
      cardTheme: cardTheme,
      listTileTheme: listTileTheme,
      timePickerTheme: timePickerTheme,
      datePickerTheme: datePickerTheme,
      dividerTheme: const DividerThemeData(color: TagAlongColors.border, thickness: 1, space: 1),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: TagAlongColors.brand),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        side: const BorderSide(color: TagAlongColors.borderStrong, width: 2),
      ),
      splashFactory: InkSparkle.splashFactory,
    );
  }
}
