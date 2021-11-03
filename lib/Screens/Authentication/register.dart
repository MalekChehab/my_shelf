import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_library/Models/user.dart';
import 'package:my_library/Widgets/book_text_form_field.dart';
import 'package:my_library/Widgets/responsive_ui.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../home_screen.dart';
import 'package:loading_overlay/loading_overlay.dart';

class Register extends StatefulWidget {
  Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  late double _height;
  late double _width;
  late double _pixelRatio;
  late bool _large;
  late bool _medium;
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  bool? _checkBoxValue = false;
  late bool _isButtonEnabled;
  final _auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;
  late String errorCode;
  late MyUser newUser;
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
                    height: _height / 10.0,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: _width / 10),
                      child: Text(
                        'Create Free Account',
                        style: Theme.of(context).textTheme.headline5,
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: _height / 30.0,
                  ),
                  form(context),
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
        top: _height / 50,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            nameTextFormField(),
            SizedBox(height: _height / 60.0),
            emailTextFormField(),
            SizedBox(height: _height / 60.0),
            passwordTextFormField(),
            SizedBox(height: _height / 60.0),
            confirmPasswordTextFormField(),
            SizedBox(height: _height / 60.0),
            Padding(
              padding: const EdgeInsets.only(
                left: 30.0,
              ),
              child: acceptTermsTextRow(),
            ),
            SizedBox(
              height: _height / 50,
            ),
            confirmButton(context),
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
            Center(
              child: googleSignUp(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget nameTextFormField() {
    return CustomTextFormField(
      hint: 'Name',
      textEditingController: _name,
      keyboardType: TextInputType.text,
      icon: Icons.person_outline_rounded,
      validator: (dynamic value) => value.isEmpty ? 'Enter a name' : null,
    );
  }

  Widget emailTextFormField() {
    return CustomTextFormField(
      hint: 'Email',
      textEditingController: _email,
      keyboardType: TextInputType.emailAddress,
      icon: Icons.mail_outline_rounded,
      validator: (dynamic value) => value.isEmpty ? 'Enter an email' : null,
    );
  }

  Widget passwordTextFormField() {
    return PasswordTextField(
      hint: 'Password',
      textEditingController: _password,
      keyboardType: TextInputType.visiblePassword,
      icon: Icons.password_outlined,
      validator: (dynamic value) =>
          value.length < 6 ? 'Must be 6 characters at least' : null,
    );
  }

  Widget confirmPasswordTextFormField() {
    return PasswordTextField(
      hint: 'Confirm Password',
      textEditingController: _confirmPassword,
      keyboardType: TextInputType.visiblePassword,
      icon: Icons.password,
      validator: (dynamic value) =>
          value != _password.text ? 'Must be the same as the password' : null,
    );
  }

  Widget acceptTermsTextRow() {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Checkbox(
              activeColor: Theme.of(context).buttonColor,
              value: _checkBoxValue,
              onChanged: (bool? newValue) {
                setState(() {
                  _checkBoxValue = newValue;
                  _isButtonEnabled = newValue!;
                });
              }),
          Text(
            "I accept all terms and conditions",
            style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: _large ? 12 : (_medium ? 11 : 10)),
          ),
        ],
      ),
    );
  }

  Widget confirmButton(BuildContext context) {
    return Button(
        elevation: 10,
        child: const Text('Register'),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            setState(() {
              _isLoading = true;
            });
            print(_name.text);
            try {
              await _auth.createUserWithEmailAndPassword(
                  email: _email.text, password: _password.text).then((user) {
                    newUser = MyUser(
                      id: _auth.currentUser!.uid,
                      name: _name.text,
                      totalBooks: 0,
                    );
                    FirebaseAuth.instance.currentUser!.updateDisplayName(_name.text);
                    db.collection('users').doc(newUser.getId()).set({
                      'name': newUser.getName(),
                      'total_books': newUser.getTotalBooks(),
                      // 'shelves':[],
                    }, SetOptions(merge: true));
                    setState(() {
                      _isLoading = false;
                    });
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => HomeScreen()),
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
            'Sign Up with Google',
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
            await FirebaseAuth.instance.signInWithCredential(credential)
                .then((value) {
                  newUser = MyUser(
                    id: _auth.currentUser!.uid,
                    name: _auth.currentUser!.displayName.toString(),
                    totalBooks: 0,
                  );
                  FirebaseAuth.instance.currentUser!.updateDisplayName(newUser.getName());
                  db.collection('users').doc(newUser.getId()).set({
                    'name': newUser.getName(),
                    // 'total_books': newUser.getTotalBooks(),
                    // 'shelves':[],
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
        return "The account already exists for that email.";
        break;
      case "weak-password":
        return "The password provided is too weak.";
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
