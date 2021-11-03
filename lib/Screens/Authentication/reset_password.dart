import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:my_library/Screens/Authentication/sign_in.dart';
import 'package:my_library/Widgets/book_text_form_field.dart';
import 'package:my_library/Widgets/responsive_ui.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ResetPassword extends StatefulWidget {
  ResetPassword({Key? key}) : super(key: key);

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final _formKey = GlobalKey<FormState>();
  late double _height;
  late double _width;
  late double _pixelRatio;
  late bool _large;
  late bool _medium;
  final TextEditingController _email = TextEditingController();
  final _auth = FirebaseAuth.instance;
  late bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
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
                        'Reset Password',
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
                    padding: const EdgeInsets.all(20.0),
                    child: confirmButton(context),
                  ),
                  SizedBox(
                    height: _height / 20.0,
                  ),
                  Align(
                    alignment: FractionalOffset.bottomCenter,
                    child: FlatButton(
                      child: const Text('Back to Sign In',),
                      onPressed: (){
                        Navigator.pop(context,
                            MaterialPageRoute(builder: (_) => SignIn()),
                        );
                      },
                    ),
                  ),
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

  late String errorCode;

  Widget confirmButton(BuildContext context) {
    return Button(
        elevation: 10,
        child: SizedBox(
          width: _width/3,
          height: _height/17,
          child: Center(
            child: Text(
              'Send Email',
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ),
        ),
        onPressed: () async {
          try {
            setState(() {
              _isLoading = true;
            });
            await _auth.
            sendPasswordResetEmail(email: _email.text).
            then((value) {
              setState(() {
                _isLoading = false;
              });
              Fluttertoast.showToast(
                msg: 'An email has been sent to ${_email.text}',
                toastLength: Toast.LENGTH_LONG,
              );
            }
            );
          } on FirebaseAuthException catch (e) {
            setState(() {
              _isLoading = false;
            });
            errorCode = e.code;
            Fluttertoast.showToast(
                msg: getMessageFromErrorCode(),
                toastLength: Toast.LENGTH_LONG,
            );
          }
        }
    );
  }

  String getMessageFromErrorCode() {
    switch (errorCode) {
      case "ERROR_EMAIL_ALREADY_IN_USE":
      case "account-exists-with-different-credential":
      case "email-already-in-use":
        return "Email already registered.";
        break;
      case "ERROR_WRONG_PASSWORD":
      case "wrong-password":
        return "Wrong email/password combination.";
        break;
      case "ERROR_USER_NOT_FOUND":
      case "user-not-found":
        return "No user found with this email.";
        break;
      case "ERROR_USER_DISABLED":
      case "user-disabled":
        return "User disabled.";
        break;
      case "ERROR_TOO_MANY_REQUESTS":
      case "operation-not-allowed":
        return "Too many requests to log into this account.";
        break;
      case "ERROR_OPERATION_NOT_ALLOWED":
        return "Server error, please try again later.";
        break;
      case "ERROR_INVALID_EMAIL":
      case "invalid-email":
        return "Email address is invalid.";
        break;
      default:
        return "Action failed. Please try again.";
        break;
    }
  }

}
