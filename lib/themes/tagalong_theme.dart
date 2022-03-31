import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TagAlongTheme {
  // 1
  static TextTheme lightTextTheme = TextTheme(
    bodyText1: GoogleFonts.nunitoSans(
      fontSize: 16.0,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.normal,
      color: Colors.black,
    ),
    // Added italics - may need to change
    bodyText2: GoogleFonts.nunitoSans(
      fontSize: 14.0,
      fontWeight: FontWeight.w400,
      fontStyle: FontStyle.italic,
      color: Colors.black,
    ),
    headline1: GoogleFonts.nunitoSans(
      fontSize: 32.0,
      fontWeight: FontWeight.normal,
      fontStyle: FontStyle.normal,
      color: Colors.black,
    ),
    headline2: GoogleFonts.nunitoSans(
      fontSize: 21.0,
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.normal,
      color: Colors.black,
    ),
    headline3: GoogleFonts.nunitoSans(
      fontSize: 16.0,
      fontWeight: FontWeight.w600,
      fontStyle: FontStyle.normal,
      color: Colors.black,
    ),
    headline6: GoogleFonts.nunitoSans(
      fontSize: 18.0,
      fontWeight: FontWeight.w600,
      fontStyle: FontStyle.normal,
      color: Colors.black,
    ),
    overline: GoogleFonts.nunitoSans(
      fontSize: 14.0,
      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.normal,
      color: const Color.fromRGBO(79, 67, 88, 87),
    ),
  );

  // 3
  static ThemeData light() {
    return ThemeData(
      primarySwatch: const MaterialColor(
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
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          // selectedItemColor: Colors.green,
          ),
      textTheme: lightTextTheme,
    );
  }
}
