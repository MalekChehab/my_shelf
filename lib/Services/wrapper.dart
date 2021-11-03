import 'package:flutter/material.dart';
import 'package:my_library/Models/user.dart';
import 'package:my_library/Screens/Authentication/welcome_screen.dart';
import 'package:my_library/Screens/home_screen.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final MyUser? user = Provider.of<MyUser?>(context);
    print('hello $user');

    // return either the Home or Authenticate widget
    if (user == null){
      return WelcomeScreen();
    } else {
      return HomeScreen();
    }

  }
}