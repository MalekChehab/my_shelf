import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_library/services/general_providers.dart';
import 'package:my_library/view/screens/auth/welcome_screen.dart';
import 'package:my_library/view/screens/home/home_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends ConsumerState<SplashScreen> {

  @override
  Widget build(BuildContext context) {
    final _authState = ref.watch(firebaseAuthProvider).currentUser;
    Future.delayed(const Duration(seconds: 4),() async{
      Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) =>
            _authState == null ? WelcomeScreen() : const HomeScreen2()),
          );
    });
    return Scaffold(
      body: Stack(fit: StackFit.expand, children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                "from",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0),
              child: Image.asset(
                'assets/images/webzone.png',
                height: 25.0,
                fit: BoxFit.scaleDown,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const <Widget>[
                // Image.asset(
                //   'assets/images/mystery_meal.png',
                //   width: 250,height: 250,
                //   // width: animation.value * 250,
                //   // height: animation.value * 250,
                // ),
              ],
            ),
          ],
        ),
      ]),
    );
  }
}