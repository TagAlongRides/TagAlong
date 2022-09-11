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
    headline1: GoogleFonts.nunitoSans(
      fontSize: 96.0,
      fontWeight: FontWeight.w300,
      fontStyle: FontStyle.normal,
      color: Colors.black,
    ),
    headline2: GoogleFonts.nunitoSans(
      fontSize: 60.0,
      fontWeight: FontWeight.w300,
      fontStyle: FontStyle.normal,
      color: Colors.black,
    ),
    headline3: GoogleFonts.nunitoSans(
      fontSize: 48.0,
      fontWeight: FontWeight.w300,
      fontStyle: FontStyle.normal,
      color: Colors.black,
    ),
    headline4: GoogleFonts.nunitoSans(
      fontSize: 34.0,
      fontWeight: FontWeight.w300,
      fontStyle: FontStyle.normal,
      color: Colors.black,
    ),
    headline5: GoogleFonts.nunitoSans(
      fontSize: 28.0,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      color: Colors.black,
    ),
    headline6: GoogleFonts.nunitoSans(
      fontSize: 22.0,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
      color: Colors.black,
    ),
    subtitle1: GoogleFonts.nunitoSans(
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      fontStyle: FontStyle.normal,
      color: Colors.black,
    ),
    subtitle2: GoogleFonts.nunitoSans(
      fontSize: 14.0,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      color: Colors.black,
    ),
    bodyText1: GoogleFonts.nunitoSans(
      fontSize: 16.0,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      color: Colors.black,
    ),
    bodyText2: GoogleFonts.nunitoSans(
      fontSize: 14.0,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
      color: Colors.black,
    ),
    button: GoogleFonts.nunitoSans(
      fontSize: 14.0,
      fontWeight: FontWeight.w300,
      fontStyle: FontStyle.normal,
      color: colorHighEmphasis,
      letterSpacing: 1,
    ),
    caption: GoogleFonts.nunitoSans(
      fontSize: 12.0,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      color: colorHighEmphasis,
    ),
    overline: GoogleFonts.nunitoSans(
      fontSize: 10.0,
      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.normal,
      color: colorHighEmphasis,
    ),
  );

  // Widget theming
  static AppBarTheme appBarTheme = AppBarTheme(
    backgroundColor: primarySwatch.shade700,
    titleTextStyle: lightTextTheme.headline6!.copyWith(
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
    unselectedLabelStyle: lightTextTheme.caption,
    selectedLabelStyle: lightTextTheme.caption!.copyWith(fontWeight: FontWeight.bold),
    type: BottomNavigationBarType.fixed,
  );

  static FloatingActionButtonThemeData floatingActionButtonTheme = FloatingActionButtonThemeData(
    foregroundColor: secondarySwatch.shade50,
    backgroundColor: primarySwatch.shade900,
  );

  static ElevatedButtonThemeData elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      textStyle: lightTextTheme.button!.copyWith(
        fontWeight: FontWeight.bold,
      ),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(1000))),
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 20,
      ),
      onPrimary: secondarySwatch.shade50,
    ),
  );

  static TextButtonThemeData textButtonTheme = TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: MaterialStateProperty.all(colorHighEmphasis),
      backgroundColor: MaterialStateProperty.all(Colors.transparent),
      textStyle: MaterialStateProperty.all(
        lightTextTheme.button!.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    ),
  );

  static OutlinedButtonThemeData outlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      alignment: Alignment.center,
      textStyle: lightTextTheme.button!.copyWith(
        fontWeight: FontWeight.bold,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 20,
      ),
      onSurface: secondarySwatch.shade50,
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
    labelStyle: lightTextTheme.subtitle2!,
    secondaryLabelStyle: lightTextTheme.subtitle2!.copyWith(color: secondarySwatch.shade50),
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
