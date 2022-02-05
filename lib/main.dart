import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_library/view/screens/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'controllers/shared_utility.dart';
import 'controllers/theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();
  await Firebase.initializeApp();
  runApp( ProviderScope(
      overrides: [
        // override the previous value with the new object
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MyApp()
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of the application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _appThemeState = ref.watch(appThemeStateProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Shelf',
      theme: ref.read(appThemeProvider)
          .getAppThemeData(context, _appThemeState),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', 'AR'),
        Locale('en', 'UK'),
      ],
      locale: const Locale('en'),
      home: const SplashScreen(),
    );
  }
}
