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
  final _service = FirebaseFirestore.instance;
  final _usersCollection = FirebaseFirestore.instance.collection('users');
  late final BehaviorSubject<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _booksController =
  BehaviorSubject<List<QueryDocumentSnapshot<Map<String, dynamic>>>>();
  late List<QueryDocumentSnapshot<Map<String, dynamic>>> booksList = [];
  late List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = [];
  late final BehaviorSubject<List<String>> _shelvesController = 
  BehaviorSubject<List<String>>();

  CollectionReference get userCollection => _usersCollection;

  Future<bool> addBook(Book book, Shelf shelf, File _imageFile) async {
    bool bookAdded = false;
    try {
      await _usersCollection.doc(uid).collection(shelf.shelfName).add(book.toFirebase()).then((doc) {
        _usersCollection.doc(uid).collection(shelf.getShelfName()).doc('shelf_data').set({
          'total_books': FieldValue.increment(1),
          'shelf_name': shelf.getShelfName(),
        }, SetOptions(merge: true));
        _usersCollection.doc(uid).set({
          "shelves": FieldValue.arrayUnion([shelf.getShelfName()]),
          "authors": FieldValue.arrayUnion(book.author.toString().split(',')),
          "tags": FieldValue.arrayUnion(book.tags.toString().split(',')),
          "genre": FieldValue.arrayUnion([book.genre]),
          "publisher": FieldValue.arrayUnion([book.publisher]),
          "total_books": FieldValue.increment(1),
        }, SetOptions(merge: true));
        if(_imageFile.path != 'no file'){
          uploadImageToFirebase('${book.title}-${book.author}.jpg', doc.id, _imageFile, shelf);
        }
        bookAdded = true;
      });
    } on FirebaseException catch (e){
      throw CustomException(message: e.message);
    }
    return bookAdded;
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
        print('Error from image repo ${snapshot.state.toString()}');
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

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getAllBooks() {
    try {
      var snap = _usersCollection.doc(uid).snapshots();
      snap.forEach((value) {
        if (value.data()!['shelves'] != null) {
          if (List.castFrom(value.data()!['shelves'])
              .isNotEmpty) {
            _shelves = List.castFrom(value.data()!['shelves'] as List);
            for (String shelf in _shelves) {
              final snapshots = _usersCollection.doc(uid).collection(shelf).snapshots();
              snapshots.forEach((snapshot){
                docs = snapshot.docs;
                for (var doc in docs) {
                  if (doc.id != 'shelf_data') {
                    if(booksList.where((book) => book.id == doc.id).isNotEmpty) {
                      booksList.removeWhere((element) => element.id == doc.id);
                    }
                    booksList.add(doc);
                    _booksController.add(booksList);
                  }
                }

              });
            }
          }
        }
      });
    }on FirebaseException catch(e){
      throw CustomException(message: e.message);
    }
    return _booksController.stream;
  }
}