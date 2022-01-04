import 'package:flutter/material.dart';

class MyThemes {
  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: const Color(0xFF1E1E1E),
    primaryColor: const Color(0xFF282828),
    backgroundColor: const Color(0xFF222222),
    indicatorColor: Colors.yellowAccent,
    buttonColor: const Color(0xFF317CFF),
    accentColor: const Color(0xFFF6F6F6),
    colorScheme: const ColorScheme.dark(),
    iconTheme: const IconThemeData(color: Color(0xFF317CFF)),
    textTheme: _darkTextTheme,
    hintColor: Colors.grey.shade300,
    appBarTheme: const AppBarTheme(
      color: Color(0xFF212121),
      brightness: Brightness.light,
    ),
    bottomAppBarColor: const Color(0xFF222222),
  );

  // static final scheme = ColorScheme(
  //     primary: const Color(0xFF1E1E1E),
      // primaryVariant: primaryVariant,
      // secondary: const Color(0xFFF6F6F6),
      // secondaryVariant: secondaryVariant,
      // surface: surface,
      // background: background,
      // error: error,
      // onPrimary: onPrimary,
      // onSecondary: onSecondary,
      // onSurface: onSurface,
      // onBackground: onBackground,
      // onError: onError,
      // brightness: brightness
  // );

  static TextTheme get _darkTextTheme {
    return const TextTheme(
      bodyText1: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Color(0xFFF6F6F6),
      ),
      caption: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 17.0,
        color: Color(0xFFB3B3B3),
        fontWeight: FontWeight.w500,
      ),
      subtitle1: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 17.0,
        color: Color(0xFF317CFF),
      ),
      subtitle2: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 17.0,
        color: Color(0xFFF6F6F6),
        fontWeight: FontWeight.w400,
      ),
      headline1: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 65,
        color: Colors.blueAccent,
      ),
      headline2: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 30,
        fontWeight: FontWeight.w300,
        color: Color(0xFFF6F6F6),
      ),
      headline3: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 18.0,
        color: Color(0xFFF6F6F6),
        fontWeight: FontWeight.w300,
      ),
      headline4: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 22.0,
        color: Colors.blueAccent,
        fontWeight: FontWeight.w300,
      ),
      headline5: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 30,
        color: Colors.blue,
        fontWeight: FontWeight.w300,
      ),
      headline6: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 16,
        color: Color(0xFF317CFF),
        fontWeight: FontWeight.bold,
      ),
      bodyText2: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 18,
        color: Color(0xFFF6F6F6),
        fontWeight: FontWeight.w400,
      ),
      button: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 15.0,
        fontWeight: FontWeight.w300,
      ),
    );
  }
}
