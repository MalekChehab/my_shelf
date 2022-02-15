import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_library/models/book.dart';
import 'package:my_library/models/shelf.dart';
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

// final authGetName = StreamProvider<String>((ref){
//   return ref.watch(authServicesProvider).getUserName().toString();
// });

final firebaseDatabaseProvider = Provider<FirebaseDatabase>((ref) {
  var _auth = ref.watch(authStateProvider);
  String uid = '';
  _auth.whenData((value) => uid = value!.uid);
  return FirebaseDatabase(uid: uid.toString());
});

final shelvesExistProvider = StreamProvider.autoDispose<bool>((ref) {
  return ref.watch(firebaseDatabaseProvider).shelvesExist();
});

final booksExistProvider = StreamProvider.autoDispose<bool>((ref) {
  return ref.watch(firebaseDatabaseProvider).booksExist();
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

final shelvesProvider = StreamProvider.autoDispose<List<Shelf>>((ref) {
  final db = ref.watch(firebaseDatabaseProvider);
  StreamController<List<Shelf>> controller = StreamController<List<Shelf>>();
  List<Shelf> list = [];
  bool shelvesExist = false;
  ref.watch(shelvesExistProvider).whenData((value) {
    return shelvesExist = value;
  });
  if (shelvesExist) {
    return db.getShelves().map((docs) => docs.map((doc) => Shelf.fromFirestore(doc)).toList());
  }
  controller.add(list);
  return controller.stream;
});