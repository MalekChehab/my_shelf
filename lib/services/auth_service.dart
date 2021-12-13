import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:my_library/services/general_providers.dart';
import 'custom_exception.dart';

class AuthenticationService {

  final FirebaseAuth _firebaseAuth;
  String? errorCode;

  AuthenticationService(this._firebaseAuth);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? getCurrentUser() {
    try {
      return _firebaseAuth.currentUser;
    } on FirebaseAuthException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  String? getUserId() {
    try {
      return _firebaseAuth.currentUser!.uid;
    } on FirebaseAuthException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  String? getUserName(){
    try{
      return _firebaseAuth.currentUser!.displayName.toString();
    } on FirebaseAuthException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  Future<bool> sendPasswordResetEmail({required String email}) async {
    bool emailSent = false;
    try{
      await _firebaseAuth.sendPasswordResetEmail(email: email)
          .then((value) => emailSent = true);
    } on FirebaseAuthException catch(e){
      errorCode = e.code;
      throw CustomException(message: _getMessageFromErrorCode());
    }
    return emailSent;
  }

  Future<bool> googleSignIn() async{
    bool logInSuccessful = false;
    try {
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
          .then((value) => logInSuccessful = true);
    } catch (e) {
      errorCode = e.toString();
      throw CustomException(message: _getMessageFromErrorCode());
    }
    return logInSuccessful;
  }

  Future<bool> register({required String email, required String password}) async{
    bool registerSuccessful = false;
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password)
          .then((value) => registerSuccessful = true);
    } on FirebaseAuthException catch (e) {
      errorCode = e.code;
      throw CustomException(message: _getMessageFromErrorCode());
    }
    return registerSuccessful;
  }

  Future<bool> signIn({required String email, required String password}) async {
    bool logInSuccessful = false;
     try {
       await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password)
           .then((value) => logInSuccessful = true);
     } on FirebaseAuthException catch (e) {
       errorCode = e.code;
       throw CustomException(message: _getMessageFromErrorCode());
     }
     return logInSuccessful;
  }

  Future<bool> signOut() async{
    bool signOutSuccessful = false;
    try {
      await _firebaseAuth.signOut();
      await GoogleSignIn().signOut().then((value) => signOutSuccessful = true);
    } on FirebaseAuthException catch (e) {
      errorCode = e.code;
      throw CustomException(message: _getMessageFromErrorCode());
    }
    return signOutSuccessful;
  }

  String _getMessageFromErrorCode() {
    switch (errorCode) {
      case "ERROR_EMAIL_ALREADY_IN_USE":
      case "account-exists-with-different-credential":
      case "email-already-in-use":
        return "An account already exists for that email.";
      case "weak-password":
        return "The password provided is too weak.";
      case "ERROR_WRONG_PASSWORD":
      case "wrong-password":
        return "Wrong email/password combination.";
      case "ERROR_USER_NOT_FOUND":
      case "user-not-found":
        return "No user found with this email.";
      case "ERROR_USER_DISABLED":
      case "user-disabled":
        return "User disabled.";
      case "ERROR_TOO_MANY_REQUESTS":
      case "operation-not-allowed":
        return "Too many requests to log into this account.";
      case "ERROR_OPERATION_NOT_ALLOWED":
        return "Server error, please try again later.";
      case "ERROR_INVALID_EMAIL":
      case "invalid-email":
        return "Email address is invalid.";
      default:
        return "Login failed. Please try again.";
    }
  }

}