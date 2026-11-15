import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TagAlongTheme {
  // TagAlong primary color swatch (light blue)
  static const MaterialColor primarySwatch = MaterialColor(
    0xff38b6ff,
    <int, Color>{
      50: Color(0xffADE1FF),
      100: Color(0xff99DAFF),
      200: Color(0xff85D2FF),
      300: Color(0xff70CBFF),
      400: Color(0xff5CC3FF),
      500: Color(0xff38B6FF),
      600: Color(0xff33B4FF),
      700: Color(0xff1FADFF),
      800: Color(0xff0AA5FF),
      900: Color(0xff009BF5),
    },
  );
  // TagAlong secondary color swatch (teal)
  static const MaterialColor secondarySwatch = MaterialColor(
    0xff5CE1E6,
    <int, Color>{
      50: Color(0xffB8F2F4),
      100: Color(0xffA7EEF1),
      200: Color(0xff95EBEE),
      300: Color(0xff83E8EC),
      400: Color(0xff72E5E9),
      500: Color(0xff5CE1E6),
      600: Color(0xff4FDEE3),
      700: Color(0xff3DDBE1),
      800: Color(0xff2BD8DE),
      900: Color(0xff21CED4),
    },
  );

  // Other colors used throughout the app
  static const Color colorHighEmphasis = Color.fromRGBO(79, 67, 88, .87);
  static const Color colorMediumEmphasis = Color.fromRGBO(145, 127, 157, .60);
  static const Color colorDisabled = Colors.black38;
  static const Color colorError = Color.fromRGBO(239, 199, 194, 1);

  // Theme to define each text style
  // Defaulting color to black in most cases, but may use .copyWith() to
  // contextually override these colors (e.g. displaying error message)
  static TextTheme lightTextTheme = TextTheme(
    displayLarge: GoogleFonts.nunitoSans(
      fontSize: 96.0,
      fontWeight: FontWeight.w300,
      fontStyle: FontStyle.normal,
      color: Colors.black,
    ),
    displayMedium: GoogleFonts.nunitoSans(
      fontSize: 60.0,
      fontWeight: FontWeight.w300,
      fontStyle: FontStyle.normal,
      color: Colors.black,
    ),
    displaySmall: GoogleFonts.nunitoSans(
      fontSize: 48.0,
      fontWeight: FontWeight.w300,
      fontStyle: FontStyle.normal,
      color: Colors.black,
    ),
    headlineMedium: GoogleFonts.nunitoSans(
      fontSize: 34.0,
      fontWeight: FontWeight.w300,
      fontStyle: FontStyle.normal,
      color: Colors.black,
    ),
    headlineSmall: GoogleFonts.nunitoSans(
      fontSize: 28.0,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      color: Colors.black,
    ),
    titleLarge: GoogleFonts.nunitoSans(
      fontSize: 22.0,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
      color: Colors.black,
    ),
    titleMedium: GoogleFonts.nunitoSans(
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      fontStyle: FontStyle.normal,
      color: Colors.black,
    ),
    titleSmall: GoogleFonts.nunitoSans(
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      color: Colors.black,
    ),
    bodyLarge: GoogleFonts.nunitoSans(
      fontSize: 16.0,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      color: Colors.black,
    ),
    bodyMedium: GoogleFonts.nunitoSans(
      fontSize: 14.0,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
      color: Colors.black,
    ),
    labelLarge: GoogleFonts.nunitoSans(
      fontSize: 14.0,
      fontWeight: FontWeight.w300,
      fontStyle: FontStyle.normal,
      color: colorHighEmphasis,
      letterSpacing: 1,
    ),
    bodySmall: GoogleFonts.nunitoSans(
      fontSize: 12.0,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      color: colorHighEmphasis,
    ),
    labelSmall: GoogleFonts.nunitoSans(
      fontSize: 10.0,
      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.normal,
      color: colorHighEmphasis,
    ),
  );

  // Widget theming
  static AppBarTheme appBarTheme = AppBarTheme(
    backgroundColor: primarySwatch.shade700,
    titleTextStyle: lightTextTheme.titleLarge!.copyWith(
      color: secondarySwatch.shade50,
    ),
    iconTheme: IconThemeData(
      color: secondarySwatch.shade50,
    ),
    elevation: 0,
  );

  static AppBarTheme progressBarTheme = const AppBarTheme(
    backgroundColor: Colors.transparent,
    iconTheme: IconThemeData(
      color: colorHighEmphasis,
      size: 18,
    ),
    elevation: 0,
  );

  static BottomNavigationBarThemeData bottomNavigationBarTheme = BottomNavigationBarThemeData(
    selectedItemColor: Colors.yellow[200],
    unselectedItemColor: secondarySwatch.shade50,
    backgroundColor: primarySwatch.shade700,
    unselectedLabelStyle: lightTextTheme.bodySmall,
    selectedLabelStyle: lightTextTheme.bodySmall!.copyWith(fontWeight: FontWeight.bold),
    type: BottomNavigationBarType.fixed,
  );

  static FloatingActionButtonThemeData floatingActionButtonTheme = FloatingActionButtonThemeData(
    foregroundColor: secondarySwatch.shade50,
    backgroundColor: primarySwatch.shade900,
  );

  static ElevatedButtonThemeData elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: secondarySwatch.shade50, textStyle: lightTextTheme.labelLarge!.copyWith(
        fontWeight: FontWeight.bold,
      ),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(1000))),
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 20,
      ),
    ),
  );

  static TextButtonThemeData textButtonTheme = TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStateProperty.all(colorHighEmphasis),
      backgroundColor: MaterialStateProperty.all(Colors.transparent),
      textStyle: MaterialStateProperty.all(
        lightTextTheme.labelLarge!.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    ),
  );

  static OutlinedButtonThemeData outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      alignment: Alignment.center,
      textStyle: lightTextTheme.labelLarge!.copyWith(
        fontWeight: FontWeight.bold,
      ), disabledForegroundColor: secondarySwatch.shade50.withOpacity(0.38),
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 20,
      ),
      // side: BorderSide.none,
      shape: RoundedRectangleBorder(
        // Using very large number to create semicircle ends of button; Flutter sets borderRadius to max allowable
        borderRadius: BorderRadius.circular(500),
        side: const BorderSide(
          color: colorHighEmphasis,
        ),
      ),
    ),
  );

  static TimePickerThemeData timePickerTheme = TimePickerThemeData(
    backgroundColor: secondarySwatch.shade50,
  );

  static DialogTheme dialogTheme = const DialogTheme();
  static BottomSheetThemeData bottomSheetTheme = const BottomSheetThemeData();

  static ChipThemeData chipTheme = ChipThemeData(
    backgroundColor: secondarySwatch.shade200,
    disabledColor: colorDisabled,
    selectedColor: primarySwatch.shade700,
    secondarySelectedColor: primarySwatch.shade700,
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
    labelStyle: lightTextTheme.titleSmall!,
    secondaryLabelStyle: lightTextTheme.titleSmall!.copyWith(color: secondarySwatch.shade50),
    brightness: Brightness.light,
    showCheckmark: true,
    checkmarkColor: Colors.white,
    side: const BorderSide(
      color: colorMediumEmphasis,
    ),
  );

  static InputDecorationTheme inputDecorationTheme = const InputDecorationTheme(
    border: UnderlineInputBorder(),
    focusedBorder: OutlineInputBorder(),
  );

  static ThemeData light() {
    return ThemeData(
      // This theme is built the Material 2 way - a primarySwatch, no
      // ColorScheme, and button colours chosen to sit on a coloured
      // background. Flutter turns Material 3 on by default from 3.16, which
      // gives ElevatedButton a pale surface background instead of the primary
      // colour, so the theme's light foreground ended up pale-on-pale and
      // every enabled button read as disabled.
      // Opting out restores the intended design. Moving the palette to a
      // ColorScheme and turning this back on is worth doing, but it is a
      // visual redesign rather than a bug fix.
      useMaterial3: false,
      primarySwatch: primarySwatch,
      canvasColor: secondarySwatch.shade50,
      textTheme: lightTextTheme,
      appBarTheme: appBarTheme,
      bottomNavigationBarTheme: bottomNavigationBarTheme,
      floatingActionButtonTheme: floatingActionButtonTheme,
      elevatedButtonTheme: elevatedButtonTheme,
      outlinedButtonTheme: outlinedButtonTheme,
      timePickerTheme: timePickerTheme,
      dialogTheme: dialogTheme,
      bottomSheetTheme: bottomSheetTheme,
      chipTheme: chipTheme,
      inputDecorationTheme: inputDecorationTheme,
      textButtonTheme: textButtonTheme,
    );
  }
}
