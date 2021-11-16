import 'package:flutter/material.dart';
import 'package:my_library/models/user.dart';
import 'package:my_library/view/screens/auth/welcome_screen.dart';
import 'package:my_library/view/screens/home/home_screen.dart';
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