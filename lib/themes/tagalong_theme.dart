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
