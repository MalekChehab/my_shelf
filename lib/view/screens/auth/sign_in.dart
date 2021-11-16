import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:my_library/models/user.dart';
import 'package:my_library/view/screens/auth/reset_password.dart';
import 'package:my_library/view/widgets/book_text_form_field.dart';
import 'package:my_library/Theme/responsive_ui.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../home/home_screen.dart';
import 'package:my_library/Services/auth.dart';

class SignIn extends StatefulWidget {
  SignIn({Key? key}) : super(key: key);

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final _formKey = GlobalKey<FormState>();
  late double _height;
  late double _width;
  late double _pixelRatio;
  late bool _large;
  late bool _medium;
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  late final FirebaseAuth _auth = FirebaseAuth.instance;
  late MyUser newUser;
  late bool _isLoading = false;
  FirebaseFirestore db = FirebaseFirestore.instance;

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
                  FlatButton(
                    child: Text('Forgot password?'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ResetPassword()),
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

  late String errorCode;

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
            setState(() {
              _isLoading = true;
            });
            try {
              await _auth
                  .signInWithEmailAndPassword(
                      email: _email.text, password: _password.text)
                  .then((value) {
                setState(() {
                  _isLoading = false;
                });
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false);
              });
            } on FirebaseAuthException catch (e) {
              setState(() {
                _isLoading = false;
              });
              errorCode = e.code;
              Fluttertoast.showToast(
                  msg: getMessageFromErrorCode(),
                  toastLength: Toast.LENGTH_LONG);
            }
          }
        });
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
            setState(() {
              _isLoading = true;
            });
            final GoogleSignInAccount? googleUser =
            await GoogleSignIn().signIn();

            // Obtain the auth details from the request
            final GoogleSignInAuthentication? googleAuth =
            await googleUser?.authentication;

            // Create a new credential
            final credential = GoogleAuthProvider.credential(
              accessToken: googleAuth?.accessToken,
              idToken: googleAuth?.idToken,
            );
            // Once signed in, return the UserCredential
            await _auth.signInWithCredential(credential)
                .then((value) {
              newUser = MyUser(
                id: _auth.currentUser!.uid,
                name: _auth.currentUser!.displayName.toString(),
                totalBooks: 0,
              );
              _auth.currentUser!.updateDisplayName(newUser.getName());
              db.collection('users').doc(newUser.getId()).set({
                'name': newUser.getName(),
              }, SetOptions(merge: true));
              setState(() {
                _isLoading = false;
              });
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => HomeScreen()),
                    (route) => false,
              );
            });
          } catch (e) {
            setState(() {
              _isLoading = false;
            });
            errorCode = e.toString();
            Fluttertoast.showToast(
              msg: getMessageFromErrorCode(),
              toastLength: Toast.LENGTH_LONG,
            );
          }
        },
      ),
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
        return "Login failed. Please try again.";
        break;
    }
  }
}
