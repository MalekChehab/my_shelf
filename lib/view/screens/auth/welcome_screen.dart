import 'package:flutter/material.dart';
import 'package:my_library/view/screens/auth/register.dart';
import 'package:my_library/view/screens/auth/sign_in.dart';
import 'package:my_library/view/widgets/book_text_form_field.dart';
import 'package:my_library/Theme/responsive_ui.dart';

class WelcomeScreen extends StatelessWidget {
  WelcomeScreen({Key? key}) : super(key: key);
  late double _height;
  late double _width;
  late double _pixelRatio;
  late bool _large;
  late bool _medium;

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    _large = ResponsiveWidget.isScreenLarge(_width, _pixelRatio);
    _medium = ResponsiveWidget.isScreenMedium(_width, _pixelRatio);
    return Material(
      child: Scaffold(
        body: Container(
          width: _width,
          height: _height,
          child: SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: _height / 10.0,
                ),
                Text("Welcome", style: Theme.of(context).textTheme.headline1),
                SizedBox(
                  height: _height / 12.0,
                ),
                SizedBox(
                  width: _width / 1.2,
                  child: Text(
                    "Let's start organizing your book library",
                    style: Theme.of(context).textTheme.headline2,
                    maxLines: 3,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: _height / 6),
                Button(
                  color: Theme.of(context).textTheme.headline1!.color,
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => Register()),
                    );
                  },
                  child: Container(
                    width: _width / 2,
                    height: _height / 13,
                    padding: const EdgeInsets.all(10),
                    child: Center(
                      child: Text(
                        'Get Started',
                        style: Theme.of(context).textTheme.headline3,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: _height / 15,),
                FlatButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => SignIn()),
                  );
                },
                    child: Text(
                      "Sign In",
                      style: Theme.of(context).textTheme.headline4,),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
