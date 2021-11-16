import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_library/view/screens/auth/welcome_screen.dart';
import 'package:my_library/view/screens/home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  // AnimationController animationController;
  // Animation<double> animation;

  void navigateUser() async {
    WidgetsFlutterBinding.ensureInitialized();
    final value = await FirebaseAuth.instance.currentUser != null;
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => value == true ? HomeScreen() : WelcomeScreen()));
  }

  startTime() async {
    var _duration = const Duration(seconds: 4);
    return Timer(_duration, navigateUser);
  }

  @override
  void initState() {
    super.initState();
    //   // animationController = new AnimationController(
    //   //     vsync: this, duration: new Duration(seconds: 2));
    //   // animation =
    //   // new CurvedAnimation(parent: animationController, curve: Curves.easeOut);
    //   //
    //   // animation.addListener(() => this.setState(() {}));
    //   // animationController.forward();
    //
    //   setState(() {
    //     _visible = !_visible;
    //   });
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("from"),
              ),
              Padding(
                  padding: const EdgeInsets.only(bottom: 30.0),
                  child: Image.asset(
                    'assets/images/webzone.png',
                    height: 25.0,
                    fit: BoxFit.scaleDown,
                  ),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
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
    );
  }
}