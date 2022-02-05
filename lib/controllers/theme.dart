import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_library/controllers/shared_utility.dart';

final appThemeProvider = Provider<MyThemes>((ref) {
  return MyThemes();
});

class MyThemes {

  ThemeData getAppThemeData(BuildContext context, bool isDarkModeEnabled) {
    return isDarkModeEnabled ? _darkThemeData : _lightThemeData;
  }
  
  static final _lightThemeData = ThemeData(
    scaffoldBackgroundColor: const Color(0xFFd5e4ff),
    primaryColor: const Color(0xFF186cff),
    backgroundColor: const Color(0xFFF6F6F6),
    indicatorColor: Colors.yellowAccent,
    buttonColor: const Color(0xFF317CFF),
    accentColor: Colors.yellowAccent,
    colorScheme: const ColorScheme.dark(),
    iconTheme: const IconThemeData(color: Color(0xFF282828)),
    textTheme: _lightTextTheme,
    hintColor: const Color(0xFF222222),
    appBarTheme: const AppBarTheme(
      color: Color(0xFF186cff),
      brightness: Brightness.light,
    ),
    bottomAppBarColor: const Color(0xFF186cff),
    listTileTheme: const ListTileThemeData(
      textColor: Color(0xFF317CFF),

    ),
    dialogBackgroundColor: Colors.grey.shade300,
  );

  static final _darkThemeData = ThemeData(
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
    listTileTheme: const ListTileThemeData(
        textColor: Color(0xFFF6F6F6),

    ),
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

  static TextTheme get _lightTextTheme {
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
        color: Color(0xFF222222),
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
        color: Color(0xFF222222),
      ),
      headline3: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 19.0,
        color: Color(0xFF222222),
        fontWeight: FontWeight.w500,
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
        color: Color(0xFF222222),
        fontWeight: FontWeight.w400,
      ),
      button: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 15.0,
        fontWeight: FontWeight.w300,
      ),
    );
  }

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

final appThemeStateProvider = StateNotifierProvider<AppThemeNotifier, bool>((ref) {
  final _isDarkModeEnabled = ref.read(sharedUtilityProvider).isDarkModeEnabled();
  return AppThemeNotifier(_isDarkModeEnabled);
});

class AppThemeNotifier extends StateNotifier<bool> {
  AppThemeNotifier(this.defaultDarkModeValue) : super(defaultDarkModeValue);

  final bool defaultDarkModeValue;

  toggleAppTheme(BuildContext context, WidgetRef ref) {
    final _isDarkModeEnabled =
    ref.read(sharedUtilityProvider).isDarkModeEnabled();
    final _toggleValue = !_isDarkModeEnabled;

    ref.read(sharedUtilityProvider,)
        .setDarkModeEnabled(_toggleValue).whenComplete(() => {
        state = _toggleValue,
      },
    );
  }
}
