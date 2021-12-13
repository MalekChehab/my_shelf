import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_library/models/book.dart';
import 'package:my_library/services/auth_service.dart';
import 'firebase_database.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final authServicesProvider = Provider<AuthenticationService>((ref) {
  return AuthenticationService(ref.read(firebaseAuthProvider));
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServicesProvider).authStateChanges;
});

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseDatabaseProvider = Provider<FirebaseDatabase>((ref) {
  var _auth = ref.watch(authServicesProvider);
  String? uid = _auth.getUserId();
  return FirebaseDatabase(uid: uid.toString());
});

final listProvider = StreamProvider.autoDispose<List<Book>>((ref) {
  final db = ref.watch(firebaseDatabaseProvider);
  return db.getAllBooks().map((docs) =>
      docs.map((doc) => Book.fromFirestore(doc)).toList());
});
