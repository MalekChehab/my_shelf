import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:my_library/services/custom_exception.dart';
import 'package:my_library/services/general_providers.dart';
import 'package:my_library/view/screens/auth/sign_in.dart';
import 'package:my_library/view/widgets/book_text_form_field.dart';
import 'package:my_library/Theme/responsive_ui.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ResetPassword extends ConsumerStatefulWidget {
  const ResetPassword({Key? key}) : super(key: key);

  @override
  ResetPasswordState createState() => ResetPasswordState();
}

class ResetPasswordState extends ConsumerState<ResetPassword> {
  final _formKey = GlobalKey<FormState>();
  late double _height;
  late double _width;
  late double _pixelRatio;
  late bool _large;
  late bool _medium;
  final TextEditingController _email = TextEditingController();
  late final bool _isLoading = false;
  late var _auth;

  @override
  Widget build(BuildContext context) {
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
                    child: TextButton(
                      child: const Text(
                        'Back to Sign In',
                      ),
                      onPressed: () {
                        Navigator.pop(
                          context,
                          MaterialPageRoute(builder: (_) => const SignIn()),
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

  Widget confirmButton(BuildContext context) {
    return Button(
        elevation: 10,
        child: SizedBox(
          width: _width / 3,
          height: _height / 17,
          child: Center(
            child: Text(
              'Send Email',
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ),
        ),
        onPressed: () async {
          try {
            bool emailSent =
                await _auth.sendPasswordResetEmail(email: _email.text);
            if (emailSent) {
              Fluttertoast.showToast(
                msg: 'An email has been sent to ${_email.text}',
                toastLength: Toast.LENGTH_LONG,
              );
            }
          } on CustomException catch (e) {
            Fluttertoast.showToast(
              msg: e.message.toString(),
              toastLength: Toast.LENGTH_LONG,
            );
          }
        });
  }
}
