import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Screens/splash_screen.dart';
import 'Theme/theme.dart';

Future main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Shelf',
      themeMode: ThemeMode.dark,
      darkTheme: MyThemes.darkTheme,
      home: SplashScreen(),
    );
  }
}