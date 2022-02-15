import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_library/services/custom_exception.dart';
import 'package:my_library/services/general_providers.dart';
import 'package:my_library/view/screens/auth/welcome_screen.dart';
import 'package:my_library/view/widgets/book_text_form_field.dart';
import 'package:my_library/controllers/responsive_ui.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../home/home_screen.dart';
import 'package:loading_overlay/loading_overlay.dart';

class Register extends ConsumerStatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  RegisterState createState() => RegisterState();
}

class RegisterState extends ConsumerState<Register> {
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
  late bool _isLoading = false;
  late var _auth;
  late var _db;

  @override
  Widget build(BuildContext context) {
    _auth = ref.watch(authServicesProvider);
    _db = ref.watch(firebaseDatabaseProvider);
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    _large = ResponsiveWidget.isScreenLarge(_width, _pixelRatio);
    _medium = ResponsiveWidget.isScreenMedium(_width, _pixelRatio);
    return Material(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
            ),
            onPressed: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const WelcomeScreen())),
          ),
        ),
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
                    height: _height / 30.0,
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
                    height: _height / 50.0,
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
              height: _height / 60,
            ),
            confirmButton(context),
            SizedBox(
              height: _height / 60,
            ),
            Divider(
              color: Theme.of(context).accentColor,
              // color: Theme.of(context).colorScheme.secondary,
              endIndent: _width / 5,
              indent: _width / 5,
            ),
            SizedBox(
              height: _height / 60,
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
      capitalization: TextCapitalization.words,
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
    return Row(
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
    );
  }

  Widget confirmButton(BuildContext context) {
    return MyButton(
        elevation: 10,
        child: const Text('Register'),
        onPressed: () async {
          setState(() {
            _isLoading = true;
          });
          if (_formKey.currentState!.validate()) {
            try {
              bool _isRegistered = await _auth.register(
                  email: _email.text, password: _password.text);
              if (_isRegistered) {
                _auth.getCurrentUser().updateDisplayName(_name.text);
                _db.updateUser(name: _name.text, uid: _auth.getUserId().toString());
                setState(() {
                  _isLoading = false;
                });
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false);
              }
            } on CustomException catch (e) {
              setState(() {
                _isLoading = false;
              });
              showToast(e.message.toString());
            }
          }else{
            setState(() {
              _isLoading = false;
            });
          }
        });
  }

  Widget googleSignUp(BuildContext context) {
    return SizedBox(
      width: _width / 2,
      child: MyButton(
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
          setState(() {
            _isLoading = true;
          });
          try {
            bool _signedIn = await _auth.googleSignIn();
            if (_signedIn) {
              _auth.getCurrentUser().updateDisplayName(_auth.getUserName());
              _db.updateUser(name: _auth.getUserName(), uid: _auth.getUserId().toString());
              setState(() {
                _isLoading = false;
              });
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false);
            }
          } on CustomException catch (e) {
            setState(() {
              _isLoading = false;
            });
            showToast(e.message.toString());
          }
        },
      ),
    );
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: Theme.of(context).iconTheme.color,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
