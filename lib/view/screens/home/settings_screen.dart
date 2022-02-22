import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:my_library/controllers/shared_utility.dart';
import 'package:my_library/controllers/theme.dart';
import 'package:my_library/services/custom_exception.dart';
import 'package:my_library/services/general_providers.dart';
import 'package:my_library/view/screens/auth/welcome_screen.dart';
import 'package:my_library/view/screens/home/shelves_screen.dart';
import 'package:my_library/view/widgets/book_text_form_field.dart';
import 'package:my_library/view/widgets/dialog.dart';
import 'package:day_night_switcher/day_night_switcher.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);
  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool isSwitched = false;
  var _auth;
  late bool _isLoading = false;
  // late var _appThemeStateProvider;
  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final _appThemeStateProvider = ref.read(appThemeStateProvider.notifier);
    final _sharedUtilityProvider = ref.read(sharedUtilityProvider);
    _auth = ref.watch(authServicesProvider);
    return Scaffold(
      // key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        progressIndicator: CircularProgressIndicator(
          color: Theme.of(context).indicatorColor,
        ),
        child: ListView(
          children: [
            const ListTile(
              title: Text('Common'),
            ),
            ListTile(
              leading: const Icon(Icons.language_rounded),
              title: const Text('Language'),
              onTap: (){},
            ),
            ListTile(
              leading: const Icon(Icons.dark_mode_rounded),
              title: const Text('Theme'),
              // trailing: ThemeModeSwitch(),
              trailing: SizedBox(
                width: 80,
                height: 51,
                child: DayNightSwitcher(
                  moonColor: Colors.white,
                  starsColor: Theme.of(context).hintColor,
                  cratersColor: Colors.grey,
                  nightBackgroundColor: Theme.of(context).primaryColor,
                  dayBackgroundColor: Theme.of(context).buttonColor,
                  sunColor: Theme.of(context).accentColor,
                  cloudsColor: Colors.cyan,
                  onStateChanged: (isDarkModeEnabled) => _appThemeStateProvider.toggleAppTheme(context, ref),
                  isDarkModeEnabled: _sharedUtilityProvider.isDarkModeEnabled(),
                ),
              )
            ),
            const ListTile(
              title: Text('Shelves'),
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Manage Shelves'),
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ShelvesScreen())
              ),
            ),
            const ListTile(
              title: Text('Account'),
            ),
            ListTile(
              leading: const Icon(Icons.person_rounded),
              title: const Text('Change Name'),
              onTap: () => changeName(),
            ),
            ListTile(
              leading: const Icon(Icons.email_rounded),
              title: const Text('Change Email'),
              onTap: () => changeEmail(),
            ),
            ListTile(
              leading: const Icon(Icons.vpn_key_rounded),
              title: const Text('Change Password'),
              onTap: () => changePassword(),
            ),
            ListTile(
              leading: const Icon(
                            Icons.delete_forever_rounded,
                            color: Colors.red,
                          ),
              title: const Text('Delete Account'),
              onTap: () => deleteAccount(),
            ),
            ListTile(
              leading: const Icon(Icons.logout_rounded),
              title: const Text('Log Out'),
              onTap: () => logOut(),
            ),
          ],
        ),
      ),
    );
  }

  changeName(){
    showDialog(context: context, builder: (_){
      TextEditingController _name = TextEditingController(text:_auth.getUserName().toString());
      return MyDialog(
        buttonLabel: 'Change',
        title: 'Change Name',
        text: 'Change your name to ',
        dialogHeight: 170,
        textField1: CustomTextFormField(
          capitalization: TextCapitalization.words,
          icon: Icons.person_rounded,
          hint: 'Name',
          textEditingController: _name,
        ),
        onPressed: () async {
          Navigator.of(context).pop();
          setState(() {
            _isLoading = true;
          });
          try {
            bool nameChanged = await _auth.changeName(newName: _name.text);
            if (nameChanged) {
              setState(() {
                _isLoading = false;
              });
              ref.refresh(authServicesProvider);
              ScaffoldMessenger.of(context)
                  .showMaterialBanner(
                MaterialBanner(
                  backgroundColor:
                  Theme.of(context)
                      .buttonColor,
                  content: const Text(
                      'Name has been changed'),
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
              Future.delayed(const Duration(seconds: 2), () {
                ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
              });

            }
          } on CustomException catch (e){
            setState(() {
              _isLoading = false;
            });
            showToast(e.message.toString());
          }
        },
      );
    });
  }

  changeEmail(){
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
            dialogHeight: 180,
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
                              showToast(e.message.toString());
                            }
                          },
                        );
                      });
                }
              } on CustomException catch (e) {
                showToast(e.message.toString());
              }
            },
          );
        });
  }

  changePassword(){
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
            dialogHeight: 220,
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
                showToast(e.message.toString());
              }
            },
          );
        });
  }

  deleteAccount(){
    showDialog(context: context, builder: (_){
      TextEditingController _emailController = TextEditingController();
      TextEditingController _passwordController = TextEditingController();
      return MyDialog(
        dialogHeight: 310,
        buttonLabel: 'I Confirm',
        title: 'Delete Account',
        text: 'Are you sure you want to delete your Account?\nAll your books and shelves will be permanently deleted.',
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
            showToast(e.message.toString());
          }
        },
      );
    });
  }

  logOut(){
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
            showToast(e.message.toString());
          }
        },
      );
    });
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