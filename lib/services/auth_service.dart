// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_library/services/firebase_database.dart';
import 'custom_exception.dart';

class AuthenticationService {

  final FirebaseAuth _firebaseAuth;
  String? errorCode;

  AuthenticationService(this._firebaseAuth);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  bool userExist(){
    try{
      return _firebaseAuth.currentUser != null;
    }on FirebaseAuthException catch (e) {
      errorCode = e.code;
      throw CustomException(message: _getMessageFromErrorCode());
    }
  }

  User? getCurrentUser() {
    try {
      return _firebaseAuth.currentUser;
    } on FirebaseAuthException catch (e) {
      errorCode = e.code;
      throw CustomException(message: _getMessageFromErrorCode());
    }
  }

  String? getUserId() {
    try {
      return _firebaseAuth.currentUser!.uid;
    } on FirebaseAuthException catch (e) {
      errorCode = e.code;
      throw CustomException(message: _getMessageFromErrorCode());
    }
  }

  String? getUserName(){
    try{
      return _firebaseAuth.currentUser!.displayName.toString();
    } on FirebaseAuthException catch (e) {
      errorCode = e.code;
      throw CustomException(message: _getMessageFromErrorCode());
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

  Future<bool> googleSignIn() async {
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

  Future<bool> register({required String email, required String password}) async {
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

  Future<bool> signOut() async {
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

  Future<bool> checkPassword({required String password}) async{
    bool passwordChecked = false;
    try{
      AuthCredential credentials = EmailAuthProvider.credential(
          email: _firebaseAuth.currentUser!.email.toString(),
          password: password
      );
      await _firebaseAuth.currentUser?.
      reauthenticateWithCredential(credentials).then((value) {
        passwordChecked = true;
      });
    } on FirebaseAuthException catch (e){
      errorCode = e.code;
      throw CustomException(message: _getMessageFromErrorCode());
    }
    return passwordChecked;
  }

  Future<bool> changeName({required String newName}) async {
    bool nameChanged = false;
    try {
      if(newName == ''){
        throw const CustomException(message: 'Please enter a name');
      }
      else {
        await _firebaseAuth.currentUser?.updateDisplayName(newName)
            .then((value) => nameChanged = true);
      }
    }on FirebaseAuthException catch (e) {
      errorCode = e.code;
      throw CustomException(message: _getMessageFromErrorCode());
    }
    return nameChanged;
  }

  Future<bool> changeEmail({required String newEmail}) async {
    bool emailChanged = false;
    try{
      await _firebaseAuth.currentUser?.updateEmail(newEmail)
          .then((value) => emailChanged = true);
    } on FirebaseAuthException catch(e){
      errorCode = e.code;
      throw CustomException(message: _getMessageFromErrorCode());
    }
    return emailChanged;
  }

  Future<bool> changePassword({required String oldPassword, required String newPassword}) async {
    bool passwordChanged = false;
    try{
      bool passwordChecked = await checkPassword(password: oldPassword);
      if(passwordChecked){
        await _firebaseAuth.currentUser?.
        updatePassword(newPassword).then((value) => passwordChanged = true);
      }
    } on FirebaseAuthException catch(e){
      errorCode = e.code;
      throw CustomException(message: _getMessageFromErrorCode());
    }
    return passwordChanged;
  }

  Future<bool> deleteUser({required String email, required String password}) async {
    bool userDeleted = false;
    try{
      AuthCredential credentials = EmailAuthProvider.credential(email: email, password: password);
      await _firebaseAuth.currentUser?.reauthenticateWithCredential(credentials).then((credentials) async {
        await FirebaseDatabase(uid: credentials.user!.uid)
            .deleteUserData(credentials.user!.uid);
        await _firebaseAuth.currentUser!.delete().then((_) async {
          return userDeleted = true;
        });
      });
    } on FirebaseAuthException catch(e){
      errorCode = e.code;
      throw CustomException(message: _getMessageFromErrorCode());
    }
    return userDeleted;
  }

  String _getMessageFromErrorCode() {
    switch (errorCode) {
      case "ERROR_EMAIL_ALREADY_IN_USE":
      case "account-exists-with-different-credential":
      case "email-already-in-use":
        return "An account already exists for that email";
      case "weak-password":
        return "The password provided is too weak";
      case "ERROR_WRONG_PASSWORD":
      case "wrong-password":
        return "Wrong password";
      case "ERROR_USER_NOT_FOUND":
      case "user-not-found":
        return "No user found with this email";
      case "ERROR_USER_DISABLED":
      case "user-disabled":
        return "User disabled";
      case "ERROR_TOO_MANY_REQUESTS":
      case "operation-not-allowed":
        return "Too many requests to log into this account";
      case "ERROR_OPERATION_NOT_ALLOWED":
        return "Server error, please try again later";
      case "ERROR_INVALID_EMAIL":
      case "invalid-email":
        return "Email address is invalid";
      default:
        return "Operation failed. Please try again.";
    }
  }

}