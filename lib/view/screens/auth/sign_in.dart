import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:my_library/services/custom_exception.dart';
import 'package:my_library/services/general_providers.dart';
import 'package:my_library/view/screens/auth/reset_password.dart';
import 'package:my_library/view/widgets/book_text_form_field.dart';
import 'package:my_library/Theme/responsive_ui.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../home/home_screen.dart';

class SignIn extends ConsumerStatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  SignInState createState() => SignInState();
}

class SignInState extends ConsumerState<SignIn> {
  final _formKey = GlobalKey<FormState>();
  late double _height;
  late double _width;
  late double _pixelRatio;
  late bool _large;
  late bool _medium;
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  late bool _isLoading = false;
  late var _auth;
  late var _db;

  @override
  Widget build(BuildContext context) {
    _db = ref.watch(firebaseFirestoreProvider);
    _auth = ref.watch(authServicesProvider);
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    _large = ResponsiveWidget.isScreenLarge(_width, _pixelRatio);
    _medium = ResponsiveWidget.isScreenMedium(_width, _pixelRatio);
    return Material(
      child: Scaffold(
        body: SizedBox(
          width: _width,
          height: _height,
          child: LoadingOverlay(
            isLoading: _isLoading,
            progressIndicator: CircularProgressIndicator(
              color: Theme.of(context).indicatorColor,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: _height / 7.0,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: _width / 10),
                      child: Text(
                        'Sign In',
                        style: Theme.of(context).textTheme.headline5,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: _height / 15.0,
                  ),
                  form(context),
                  SizedBox(
                    height: _height / 30.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: confirmButton(context),
                  ),
                  SizedBox(
                    height: _height / 40.0,
                  ),
                  TextButton(
                    child: const Text('Forgot password?'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ResetPassword()),
                      );
                    },
                  ),
                  SizedBox(
                    height: _height / 50,
                  ),
                  Divider(
                    color: Theme.of(context).accentColor,
                    endIndent: _width / 5,
                    indent: _width / 5,
                  ),
                  SizedBox(
                    height: _height / 50,
                  ),
                  googleSignUp(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget form(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: _width / 12,
        right: _width / 12,
        top: _height / 30,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            emailTextFormField(),
            SizedBox(height: _height / 60.0),
            passwordTextFormField(),
            SizedBox(height: _height / 60.0),
          ],
        ),
      ),
    );
  }

  Widget emailTextFormField() {
    return CustomTextFormField(
      hint: 'Email',
      textEditingController: _email,
      keyboardType: TextInputType.emailAddress,
      icon: Icons.mail_outline_rounded,
      validator: (dynamic value) {
        if (value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );
  }

  Widget passwordTextFormField() {
    return PasswordTextField(
      hint: 'Password',
      textEditingController: _password,
      keyboardType: TextInputType.visiblePassword,
      icon: Icons.password_outlined,
    );
  }

  Widget confirmButton(BuildContext context) {
    return Button(
        elevation: 10,
        child: SizedBox(
          width: _width / 3,
          height: _height / 17,
          child: Center(
            child: Text(
              'Sign In',
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ),
        ),
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          try {
            bool _signedIn = await _auth.signIn(email: _email.text, password: _password.text);
            if (_signedIn) {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false);
            }
          } on CustomException catch (e) {
            Fluttertoast.showToast(
                msg: e.message.toString(), toastLength: Toast.LENGTH_LONG);
          }
        }
      },
    );
  }

  Widget googleSignUp(BuildContext context) {
    return SizedBox(
      height: _height / 5,
      width: _width / 2,
      child: Button(
        color: Theme.of(context).accentColor,
        child: Row(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              FontAwesomeIcons.google,
              color: Theme.of(context).primaryColor,
              size: 16,
            ),
          ),
          Text(
            'Sign In with Google',
            style: TextStyle(color: Theme.of(context).buttonColor),
          ),
        ]),
        onPressed: () async {
          try {
            bool _signedIn = await _auth.googleSignIn();
            if (_signedIn) {
              _auth.getCurrentUser().updateDisplayName(_auth.getUserName());
              _db.collection('users').doc(_auth.getUserId()).set({
                'name':_auth.getUserName(),
              }, SetOptions(merge: true));
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false);
            }
          } on CustomException catch (e) {
            Fluttertoast.showToast(
                msg: e.message.toString(), toastLength: Toast.LENGTH_LONG);
          }
        },
      ),
    );
  }
}
