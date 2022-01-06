import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:my_library/models/book.dart';
import 'package:my_library/models/shelf.dart';
import 'package:my_library/services/custom_exception.dart';
import 'package:rxdart/rxdart.dart';

class FirebaseDatabase{
  FirebaseDatabase({required this.uid});
  final String uid;
  late List<String> _shelves = [];
  // final _service = FirebaseFirestore.instance;
  final _usersCollection = FirebaseFirestore.instance.collection('users');
  late final BehaviorSubject<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _booksController =
  BehaviorSubject<List<QueryDocumentSnapshot<Map<String, dynamic>>>>();
  late List<QueryDocumentSnapshot<Map<String, dynamic>>> booksList = [];
  late List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = [];
  late final BehaviorSubject<List<String>> _shelvesController = 
  BehaviorSubject<List<String>>();
  late final BehaviorSubject<bool> _shelvesExistController = BehaviorSubject<bool>();
  late final BehaviorSubject<bool> _booksExistController = BehaviorSubject<bool>();

  CollectionReference get userCollection => _usersCollection;

  Future<void> updateUser(String name, String _uid) async{
    await _usersCollection.doc(_uid).set({
      'name': name,
    },SetOptions(merge: true));
  }

  Future<bool> addBook(Book book, Shelf shelf, File _imageFile) async {
    bool bookAdded = false;
    try {
      await _usersCollection.doc(uid).collection(shelf.shelfName).add(book.toFirebase()).then((doc) {
        doc.set({
          "date_added": FieldValue.serverTimestamp(),
          "pages_read": 0,
          "rating": 0.0,
          "is_reading": false,
          "is_finished": false,
          "times_read": 0,
          "start_reading": DateTime(1000,1,1),
          "end_reading": DateTime(1000, 1,1),
        }, SetOptions(merge: true));
        _usersCollection.doc(uid).collection(shelf.getShelfName()).doc('shelf_data').set({
          'total_shelf_books': FieldValue.increment(1),
          'shelf_name': shelf.getShelfName(),
        }, SetOptions(merge: true));
        _usersCollection.doc(uid).set({
          "shelves": FieldValue.arrayUnion([shelf.getShelfName()]),
          "authors": FieldValue.arrayUnion(book.author),
          "tags": FieldValue.arrayUnion(book.tags!.toList()),
          "genre": FieldValue.arrayUnion([book.genre]),
          "publisher": FieldValue.arrayUnion([book.publisher]),
          "language": FieldValue.arrayUnion([book.language]),
          "total_books": FieldValue.increment(1),
        }, SetOptions(merge: true));
        if(_imageFile.path != 'no file'){
          uploadImageToFirebase('${book.id}.jpg', doc.id, _imageFile, shelf);
        }
        bookAdded = true;
      });
    } on FirebaseException catch (e){
      throw CustomException(message: e.message);
    }
    return bookAdded;
  }

  Future<bool> editBook(Book newBook, Shelf shelf, File _imageFile) async {
    bool bookEdited = false;
    try {
      await _usersCollection.doc(uid).collection(shelf.shelfName)
          .doc(newBook.id.toString()).update(newBook.toFirebase()).then((value) {
        _usersCollection.doc(uid).set({
          "authors": FieldValue.arrayUnion(newBook.author),
          "tags": FieldValue.arrayUnion(newBook.tags!.toList()),
          "genre": FieldValue.arrayUnion([newBook.genre]),
          "publisher": FieldValue.arrayUnion([newBook.publisher]),
          "language": FieldValue.arrayUnion([newBook.language]),
        }, SetOptions(merge: true));
        if(_imageFile.path != 'no file'){
          uploadImageToFirebase('${newBook.id}.jpg', newBook.id.toString(), _imageFile, shelf);
        }
        bookEdited = true;
      });
    } on FirebaseException catch (e){
      throw CustomException(message: e.message);
    }
    return bookEdited;
  }

  Future uploadImageToFirebase(String fileName, String docId, File _imageFile, Shelf shelf) async {
    try {
      TaskSnapshot snapshot = await FirebaseStorage.instance
          .ref('$uid/book_covers/$fileName')
          .putFile(_imageFile);
      if (snapshot.state == TaskState.success) {
        final String downloadUrl = await snapshot.ref.getDownloadURL();
        await _usersCollection.doc(uid)
            .collection(shelf.getShelfName()).doc(docId).set({
          "cover": downloadUrl,
        }, SetOptions(merge: true));
      } else {
        // print('Error from image repo ${snapshot.state.toString()}');
        throw ('This file is not an image');
      }
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  Stream<List<String>> getShelves() {
    try{
      var snapshots = _usersCollection.doc(uid).snapshots();
        snapshots.forEach((snapshot) {
        if(snapshot.data()!['shelves'] != null) {
          if (List.castFrom(snapshot.data()!['shelves']).isNotEmpty) {
            _shelves = List.castFrom(snapshot.data()!['shelves'] as List);
            _shelvesController.add(_shelves);
          }
        }
      });
    }on FirebaseException catch(e){
      throw CustomException(message: e.message);
    }
    return _shelvesController.stream;
  }

  Stream<bool> shelvesExist() {
    if(uid.isNotEmpty) {
      var snapshots = _usersCollection.doc(uid).snapshots();
      snapshots.forEach((snapshot) {
        if (snapshot.data()!['shelves'] != null) {
          _shelvesExistController.add(true);
        }
      });
    }
    return _shelvesExistController.stream;
  }

  Stream<bool> booksExist() {
    if(uid.isNotEmpty) {
      var snapshots = _usersCollection.doc(uid).snapshots();
      snapshots.forEach((snapshot) {
        if (snapshot.data()!['total_books'] !=null && snapshot.data()!['total_books'] > 0 ) {
          _booksExistController.add(true);
        }
      });
    }
    return _booksExistController.stream;
  }

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getAllBooks() {
    try {
      if(uid.isNotEmpty) {
        var snapshots = _usersCollection.doc(uid).snapshots();
        snapshots.forEach((value) {
          if (value.data() == null) {
            throw const CustomException(message: 'no books');
          } else if (value.data()!['shelves'] != null) {
            if (List
                .castFrom(value.data()!['shelves'])
                .isNotEmpty) {
              _shelves = List.castFrom(value.data()!['shelves'] as List);
              for (String shelf in _shelves) {
                final snapshots = _usersCollection.doc(uid)
                    .collection(shelf)
                    .snapshots();
                snapshots.forEach((snapshot) {
                  docs = snapshot.docs;
                  for (var doc in docs) {
                    if (doc.id != 'shelf_data') {
                      if (booksList
                          .where((book) => book.id == doc.id)
                          .isNotEmpty) {
                        booksList.removeWhere((element) =>
                        element.id == doc.id);
                      }
                      booksList.add(doc);
                      _booksController.add(booksList);
                    }
                  }
                });
              }
            }
          }
          else if(value.data()!['shelves'] == null){
            throw const CustomException(message: 'no books');
          }
        });
      }
    }on FirebaseException catch(e){
      throw CustomException(message: e.message);
    }
    return _booksController.stream;
  }

  Future<bool> deleteBook(Book book) async {
    bool bookDeleted = false;
    try{
      await _usersCollection.doc(uid).collection(book.shelf!.getShelfName()).doc(book.id).delete().then((value){
        booksList.removeWhere((element) => element.id == book.id);
        _booksController.add(booksList);
        _usersCollection.doc(uid).collection(book.shelf!.getShelfName()).doc('shelf_data').set({
          'total_shelf_books': FieldValue.increment(-1),
        }, SetOptions(merge: true));
        _usersCollection.doc(uid).set({
          "total_books": FieldValue.increment(-1),
        }, SetOptions(merge: true));
        if(book.coverUrl != "") {
          FirebaseStorage.instance.ref('$uid/book_covers/${book.id}.jpg')
              .delete();
        }
        bookDeleted = true;
      });
    } on FirebaseException catch (e){
      throw CustomException(message: e.message);
    }
    return bookDeleted;
  }

  // Future<bool> addBook2(Book book, File _imageFile) async {
  //   bool bookAdded = false;
  //   try {
  //     await _usersCollection.doc(uid).collection('books').add(book.toFirebase()).then((doc) {
  //       doc.set({
  //         "date_added": FieldValue.serverTimestamp(),
  //         "pages_read": 0,
  //         "rating": 0.0,
  //         "is_reading": false,
  //         "is_finished": false,
  //         "times_read": 0,
  //         "start_reading": DateTime(1000,1,1),
  //         "end_reading": DateTime(1000, 1,1),
  //       }, SetOptions(merge: true));
  //       // _usersCollection.doc(uid).collection(shelf.getShelfName()).doc('shelf_data').set({
  //       //   'total_shelf_books': FieldValue.increment(1),
  //       //   'shelf_name': book.shelf!.getShelfName(),
  //       // }, SetOptions(merge: true));
  //       _usersCollection.doc(uid).set({
  //         "shelves2": FieldValue.arrayUnion([{book.shelf!.getShelfName() : FieldValue.increment(1)}]),
  //         "authors": FieldValue.arrayUnion(book.author),
  //         "tags": FieldValue.arrayUnion(book.tags!.toList()),
  //         "genre": FieldValue.arrayUnion([book.genre]),
  //         "publisher": FieldValue.arrayUnion([book.publisher]),
  //         "language": FieldValue.arrayUnion([book.language]),
  //         "total_books": FieldValue.increment(1),
  //       }, SetOptions(merge: true));
  //       if(_imageFile.path != 'no file'){
  //         uploadImageToFirebase2('${book.id}.jpg', doc.id, _imageFile);
  //       }
  //       bookAdded = true;
  //     });
  //   } on FirebaseException catch (e){
  //     throw CustomException(message: e.message);
  //   }
  //   return bookAdded;
  // }

  // Future uploadImageToFirebase2(String fileName, String docId, File _imageFile) async {
  //   try {
  //     TaskSnapshot snapshot = await FirebaseStorage.instance
  //         .ref('$uid/book_covers/$fileName')
  //         .putFile(_imageFile);
  //     if (snapshot.state == TaskState.success) {
  //       final String downloadUrl = await snapshot.ref.getDownloadURL();
  //       await _usersCollection.doc(uid)
  //           .collection('books').doc(docId).set({
  //         "cover": downloadUrl,
  //       }, SetOptions(merge: true));
  //     } else {
  //       // print('Error from image repo ${snapshot.state.toString()}');
  //       throw ('This file is not an image');
  //     }
  //   } on FirebaseException catch (e) {
  //     throw CustomException(message: e.message);
  //   }
  // }
}