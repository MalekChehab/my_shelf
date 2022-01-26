import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:my_library/services/custom_exception.dart';
import 'package:my_library/services/general_providers.dart';
import 'package:my_library/view/screens/auth/welcome_screen.dart';
import 'package:my_library/view/widgets/book_text_form_field.dart';
import 'package:my_library/view/widgets/dialog.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);
  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool isSwitched = false;
  var _auth;
  late bool _isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    _auth = ref.watch(authServicesProvider);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        progressIndicator: CircularProgressIndicator(
          color: Theme.of(context).indicatorColor,
        ),
        child: SettingsList(
          sections: [
            SettingsSection(
              title: const Text('Theme'),
              tiles: [
                SettingsTile(
                  title: const Text('Language'),
                  // subtitle: 'English',
                  leading: const Icon(Icons.language),
                  onPressed: (BuildContext context) {},
                ),
                SettingsTile(
                  title: const Text('Theme'),
                  // subtitle: 'English',
                  leading: const Icon(Icons.dark_mode_rounded),
                  onPressed: (BuildContext context) {},
                ),
                SettingsTile.switchTile(
                  title: const Text('Use System Theme'),
                  leading: const Icon(Icons.phone_android),
                  // switchValue: isSwitched,
                  onToggle: (value) {
                    setState(() {
                      isSwitched = value;
                    });
                  },
                  initialValue: false,
                ),
              ],
            ),
            SettingsSection(
              title: const Text('Shelves'),
              tiles: [
                SettingsTile(
                  title: const Text('Security'),
                  leading: const Icon(Icons.lock),
                  onPressed: (BuildContext context) {},
                ),
                SettingsTile.switchTile(
                  title: const Text('Use fingerprint'),
                  leading: const Icon(Icons.fingerprint),
                  onToggle: (value) {}, initialValue: null,
                ),
              ],
            ),
            SettingsSection(
              title: const Text('Account'),
              tiles: [
                // change email tile
                SettingsTile(
                  title: const Text('Change email'),
                  leading: const Icon(Icons.email_rounded),
                  onPressed: (_) {
                    showDialog(
                        context: context,
                        builder: (_) {
                          TextEditingController _passwordController =
                          TextEditingController();
                          TextEditingController _emailController =
                          TextEditingController();
                          return MyDialog(
                            buttonLabel: 'Proceed',
                            text:
                                'Please enter your password in order to change your email',
                            title: 'Change Email',
                            dialogHeight: 190,
                            textField1: PasswordTextField(
                              icon: Icons.password_rounded,
                              hint: 'Password',
                              textEditingController: _passwordController,
                              keyboardType: TextInputType.visiblePassword,
                            ),
                            onPressed: () async { // check password is correct
                              try {
                                bool passwordChecked = await _auth
                                    .checkPassword(password: _passwordController.text);
                                if (passwordChecked) {
                                  Navigator.pop(context);
                                  showDialog(
                                      context: context,
                                      builder: (_) {
                                        return MyDialog(
                                          buttonLabel: 'Change',
                                          text: 'Please enter your new email',
                                          title: 'Change Email',
                                          dialogHeight: 170,
                                          textField1: CustomTextFormField(
                                            icon: Icons.email_rounded,
                                            hint: 'New Email',
                                            textEditingController:
                                                _emailController,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                          ),
                                          onPressed: () async { // change email
                                            Navigator.pop(context);
                                            setState(() {
                                              _isLoading = true;
                                            });
                                            try {
                                              bool emailUpdated =
                                                  await _auth.changeEmail(
                                                      newEmail: _emailController.text);
                                              if (emailUpdated) {
                                                setState(() {
                                                  _isLoading = false;
                                                });
                                                ScaffoldMessenger.of(context)
                                                    .showMaterialBanner(
                                                  MaterialBanner(
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .buttonColor,
                                                    content: const Text(
                                                        'Email has been updated'),
                                                    actions: [
                                                      TextButton(
                                                        child: const Text(
                                                            'Dismiss'),
                                                        onPressed: () =>
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .hideCurrentMaterialBanner(),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                Future.delayed(const Duration(seconds: 3), () {
                                                  ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
                                                });
                                              }
                                            } on CustomException catch (e) {
                                              setState(() {
                                                _isLoading = false;
                                              });
                                              Fluttertoast.showToast(
                                                msg: e.message.toString(),
                                                toastLength: Toast.LENGTH_LONG,
                                                backgroundColor: Theme.of(context).buttonColor,
                                              );
                                            }
                                          },
                                        );
                                      });
                                }
                              } on CustomException catch (e) {
                                Fluttertoast.showToast(
                                  msg: e.message.toString(),
                                  toastLength: Toast.LENGTH_LONG,
                                  backgroundColor: Theme.of(context).buttonColor,
                                );
                              }
                            },
                          );
                        });
                  },
                ),
                // change password tile
                SettingsTile(
                  title: const Text('Change Password'),
                  leading: const Icon(Icons.vpn_key_rounded),
                  onPressed: (_) { // show dialog
                    showDialog(
                        context: context,
                        builder: (_) {
                          TextEditingController _oldPasswordController =
                          TextEditingController();
                          TextEditingController _newPasswordController =
                          TextEditingController();
                          return MyDialog(
                            buttonLabel: 'Change',
                            title: 'Change Password',
                            dialogHeight: 200,
                            textField1: PasswordTextField(
                              icon: Icons.password_rounded,
                              hint: 'Old Password',
                              hintStyle: const TextStyle(fontSize: 13),
                              textEditingController: _oldPasswordController,
                              keyboardType: TextInputType.visiblePassword,
                            ),
                            textField2: PasswordTextField(
                              icon: Icons.password_rounded,
                              hint: 'New Password',
                              hintStyle: const TextStyle(fontSize: 13),
                              textEditingController: _newPasswordController,
                              keyboardType: TextInputType.visiblePassword,
                            ),
                            onPressed: () async { // change password
                              Navigator.pop(context);
                              setState(() {
                                _isLoading = true;
                              });
                              try {
                                bool passwordChanged = await _auth.changePassword(
                                    oldPassword: _oldPasswordController.text,
                                    newPassword: _newPasswordController.text);
                                if(passwordChanged){
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  ScaffoldMessenger.of(context)
                                      .showMaterialBanner(
                                    MaterialBanner(
                                      backgroundColor:
                                      Theme.of(context)
                                          .buttonColor,
                                      content: const Text(
                                          'Password has been updated'),
                                      actions: [
                                        TextButton(
                                          child: const Text(
                                              'Dismiss'),
                                          onPressed: () =>
                                              ScaffoldMessenger
                                                  .of(context)
                                                  .hideCurrentMaterialBanner(),
                                        ),
                                      ],
                                    ),
                                  );
                                  Future.delayed(const Duration(seconds: 3), () {
                                    ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
                                  });
                                }
                              } on CustomException catch (e) {
                                setState((){
                                  _isLoading = false;
                                });
                                Fluttertoast.showToast(
                                  msg: e.message.toString(),
                                  toastLength: Toast.LENGTH_LONG,
                                  backgroundColor: Theme.of(context).buttonColor,
                                );
                              }
                            },
                          );
                        });
                  },
                ),
                // delete account tile
                SettingsTile(
                  title: const Text('Delete account'),
                  leading: const Icon(
                    Icons.delete_forever_rounded,
                    color: Colors.red,
                  ),
                  onPressed: (_) {
                    showDialog(context: context, builder: (_){
                      TextEditingController _emailController = TextEditingController();
                      TextEditingController _passwordController = TextEditingController();
                      return MyDialog(
                        dialogHeight: 290,
                          buttonLabel: 'I Confirm',
                          title: 'Delete Account',
                          text: 'Are you sure you want to delete your Account?\nAll your books and shelves will be deleted.',
                          textField1: CustomTextFormField(
                            textEditingController: _emailController,
                            hint: 'Email',
                            icon: Icons.email_rounded,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          textField2: PasswordTextField(
                            textEditingController: _passwordController,
                            hint: 'Password',
                            icon: Icons.password_rounded,
                            keyboardType: TextInputType.visiblePassword,
                          ),
                          onPressed: () async {
                            Navigator.pop(context);
                            setState(() {
                              _isLoading = true;
                            });
                            try{
                              bool accountDeleted = await _auth.deleteUser(
                                  email: _emailController.text,
                                  password: _passwordController.text);
                              if(accountDeleted){
                                setState(() {
                                  _isLoading = false;
                                });
                                Navigator.pushAndRemoveUntil(
                                    context, MaterialPageRoute(
                                    builder: (_) => const WelcomeScreen()), (route) => false);
                              }
                            } on CustomException catch  (e){
                              setState(() {
                                _isLoading = false;
                              });
                              Fluttertoast.showToast(
                                msg: e.message.toString(),
                                toastLength: Toast.LENGTH_LONG,
                                backgroundColor: Theme.of(context).buttonColor,
                              );
                            }
                          },
                          );
                    });
                  },
                ),
                // log out tile
                SettingsTile(
                  title: const Text('Log out'),
                  leading: const Icon(Icons.logout_rounded),
                  onPressed: (_) {
                    showDialog(context: context, builder: (_){
                      return MyDialog(
                          buttonLabel: 'Log Out',
                          title: 'Log Out',
                          text: 'Are you sure you want to log out?',
                          dialogHeight: 105,
                          onPressed: () async {
                            Navigator.of(context).pop();
                            setState(() {
                              _isLoading = true;
                            });
                            try {
                              bool loggedOut = await _auth.signOut();
                              if (loggedOut) {
                                setState(() {
                                  _isLoading = false;
                                });
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const WelcomeScreen()),
                                        (route) => false);
                              }
                            } on CustomException catch (e){
                              setState(() {
                                _isLoading = false;
                              });
                              Fluttertoast.showToast(
                                msg: e.message.toString(),
                                toastLength: Toast.LENGTH_LONG,
                                backgroundColor: Theme.of(context).buttonColor,
                              );
                            }
                          },
                          );
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
