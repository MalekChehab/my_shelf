import 'dart:async';

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

final firebaseDatabaseProvider = Provider<FirebaseDatabase>((ref) {
  var _auth = ref.watch(authStateProvider);
  String uid = '';
  _auth.whenData((value) => uid = value!.uid);
  return FirebaseDatabase(uid: uid.toString());
});

final allBooksProvider = StreamProvider.autoDispose<List<Book>>((ref) {
  final db = ref.watch(firebaseDatabaseProvider);
  StreamController<List<Book>> controller = StreamController<List<Book>>();
  List<Book> list = [];
  bool shelvesExist = false;
  ref.watch(booksExistProvider).whenData((value) => shelvesExist = value);
  if (shelvesExist) {
    return db
        .getAllBooks()
        .map((docs) => docs.map((doc) => Book.fromFirestore(doc)).toList());
  }
  controller.add(list);
  return controller.stream;
});

final shelvesProvider = StreamProvider.autoDispose<List<String>>((ref) {
  final _shelvesList = ref.watch(firebaseDatabaseProvider).getShelves();
  StreamController<List<String>> controller = StreamController<List<String>>();
  List<String> list = [];
  bool shelvesExist = false;
  ref.watch(shelvesExistProvider).whenData((value) => shelvesExist = value);
  if (shelvesExist) {
    return _shelvesList;
  }
  controller.add(list);
  return controller.stream;
});

final shelvesExistProvider = StreamProvider<bool>((ref) {
  return ref.watch(firebaseDatabaseProvider).shelvesExist();
});

final booksExistProvider = StreamProvider<bool>((ref) {
  return ref.watch(firebaseDatabaseProvider).booksExist();
});