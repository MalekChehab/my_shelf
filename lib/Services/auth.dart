// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:my_library/Models/user.dart';
// import 'package:firebase_auth/firebase_auth.dart';
//
// class AuthService {
//
//   final _firebaseAuth = FirebaseAuth.instance;
//   late String errorCode;
//
//   String getMessageFromErrorCode() {
//     switch (errorCode) {
//       case "ERROR_EMAIL_ALREADY_IN_USE":
//       case "account-exists-with-different-credential":
//       case "email-already-in-use":
//         return "The account already exists for that email.";
//         break;
//       case "weak-password":
//         return "The password provided is too weak.";
//         break;
//       case "ERROR_WRONG_PASSWORD":
//       case "wrong-password":
//         return "Wrong email/password combination.";
//         break;
//       case "ERROR_USER_NOT_FOUND":
//       case "user-not-found":
//         return "No user found with this email.";
//         break;
//       case "ERROR_USER_DISABLED":
//       case "user-disabled":
//         return "User disabled.";
//         break;
//       case "ERROR_TOO_MANY_REQUESTS":
//       case "operation-not-allowed":
//         return "Too many requests to log into this account.";
//         break;
//       case "ERROR_OPERATION_NOT_ALLOWED":
//         return "Server error, please try again later.";
//         break;
//       case "ERROR_INVALID_EMAIL":
//       case "invalid-email":
//         return "Email address is invalid.";
//         break;
//       default:
//         return "Login failed. Please try again.";
//         break;
//     }
//   }
//
//   MyUser? _userFromFirebase(User? user) {
//     if (user == null) {
//       return null;
//     }
//     return MyUser(id: user.uid, name: user.displayName.toString());
//   }
//
//   Stream<MyUser?> get authStateChanges {
//     return _firebaseAuth
//         .authStateChanges()
//         .map((User? user) => _userFromFirebase(user));
//   }
//
//   Future<MyUser?> currentUser() async {
//     final user = _firebaseAuth.currentUser;
//     return _userFromFirebase(user);
//   }
//
//   Future<MyUser?> signInAnonymously() async {
//     final authResult = await _firebaseAuth.signInAnonymously();
//     return _userFromFirebase(authResult.user);
//   }
//
//   Future<MyUser?> signInWithEmailAndPassword(
//       String email, String password) async {
//     try {
//       final authResult = await _firebaseAuth.signInWithEmailAndPassword(
//           email: email, password: password);
//       return _userFromFirebase(authResult.user);
//     } on FirebaseAuthException catch (e) {
//       errorCode = e.code;
//       Fluttertoast.showToast(
//           msg: getMessageFromErrorCode(), toastLength: Toast.LENGTH_LONG);
//     }
//   }
//
//   Future<MyUser?> registerWithEmailAndPassword(
//       String email, String password) async {
//     try {
//       final authResult = await _firebaseAuth.createUserWithEmailAndPassword(
//           email: email, password: password);
//       return _userFromFirebase(authResult.user);
//     } on FirebaseAuthException catch (e) {
//       errorCode = e.code;
//       Fluttertoast.showToast(
//           msg: getMessageFromErrorCode(), toastLength: Toast.LENGTH_LONG);
//     }
//   }
//
//   Future<MyUser?> signInWithGoogle() async {
//     try {
//       final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//
//       // Obtain the auth details from the request
//       final GoogleSignInAuthentication? googleAuth =
//           await googleUser?.authentication;
//
//       // Create a new credential
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth?.accessToken,
//         idToken: googleAuth?.idToken,
//       );
//       // Once signed in, return the UserCredential
//       final authResult =
//           await FirebaseAuth.instance.signInWithCredential(credential);
//       return _userFromFirebase(authResult.user);
//     } on FirebaseAuthException catch (e) {
//       errorCode = e.code;
//       Fluttertoast.showToast(
//           msg: getMessageFromErrorCode(), toastLength: Toast.LENGTH_LONG);
//     }
//   }
//
//   Future<String> signOut() async {
//     try {
//       final googleSignin = GoogleSignIn();
//       await googleSignin.signOut();
//       await _firebaseAuth.signOut();
//       return "Sign out success";
//     } on FirebaseAuthException catch (e) {
//       errorCode = e.code;
//     //   Fluttertoast.showToast(
//     //       msg: getMessageFromErrorCode(), toastLength: Toast.LENGTH_LONG);
//       return getMessageFromErrorCode();
//     }
//   }
// }
