import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_library/models/book.dart';
import 'package:my_library/models/shelf.dart';
import 'package:my_library/services/custom_exception.dart';
import 'package:rxdart/rxdart.dart';
import 'package:blurhash/blurhash.dart' as blur;

class FirebaseDatabase {
  FirebaseDatabase({required this.uid});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? uid;
  final _usersCollection = FirebaseFirestore.instance.collection('users');
  late final BehaviorSubject<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      _booksController =
      BehaviorSubject<List<QueryDocumentSnapshot<Map<String, dynamic>>>>();
  late final List<QueryDocumentSnapshot<Map<String, dynamic>>> _booksList = [];
  late final List<QueryDocumentSnapshot<Map<String, dynamic>>> _shelves = [];
  late final BehaviorSubject<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      _shelvesController =
      BehaviorSubject<List<QueryDocumentSnapshot<Map<String, dynamic>>>>();
  late final BehaviorSubject<bool> _shelvesExistController =
      BehaviorSubject<bool>();
  late final BehaviorSubject<bool> _booksExistController =
      BehaviorSubject<bool>();

  CollectionReference get userCollection => _usersCollection;

  Future<void> updateUser({required String name, String? uid}) async {
    await _usersCollection.doc(uid ?? this.uid).set({
      'name': name,
    }, SetOptions(merge: true));
  }

  Stream<bool> shelvesExist() {
    if (uid != null) {
      var snapshots = _usersCollection.doc(uid).snapshots();
      snapshots.forEach((snapshot) {
        if (snapshot.data()!['shelves'] != null &&
            snapshot.data()!['nb_of_shelves'] > 0) {
          _shelvesExistController.add(true);
        }
      });
    }
    return _shelvesExistController.stream;
  }

  Stream<bool> booksExist() {
    if (uid != null) {
      var snapshots = _usersCollection.doc(uid).snapshots();
      snapshots.forEach((snapshot) {
        if (snapshot.data()!['total_books'] != null &&
            snapshot.data()!['total_books'] > 0) {
          _booksExistController.add(true);
        }
      });
    }
    return _booksExistController.stream;
  }

  Future<bool> checkShelf(Shelf shelf) async {
    bool exist = false;
    try {
      List<String> _stringShelves = [];
      await _usersCollection.doc(uid).get().then((snapshot) {
        if (snapshot.data()!['shelves'] != null) {
          if (List.castFrom(snapshot.data()!['shelves']).isNotEmpty) {
            _stringShelves = List.castFrom(snapshot.data()!['shelves'] as List);
          }
        }
      });
      if (_stringShelves.contains(shelf.shelfName)) {
        exist = true;
      }
    } on Exception catch (e) {
      throw CustomException(message: e.toString());
    }
    return exist;
  }

  Future<bool> addShelf(Shelf shelf) async {
    bool shelfAdded = false;
    try {
      await _firestore.runTransaction((transaction) async {
        DocumentReference userDoc = _usersCollection.doc(uid);
        CollectionReference shelvesCollection = userDoc.collection('shelves');
        await shelvesCollection.add(shelf.toFirebase()).then((doc) {
          transaction.set(
              doc,
              {
                'date_added': FieldValue.serverTimestamp(),
              },
              SetOptions(
                merge: true,
              ));
          transaction.set(
              userDoc,
              {
                'nb_of_shelves': FieldValue.increment(1),
                'shelves': FieldValue.arrayUnion([shelf.shelfName]),
              },
              SetOptions(
                merge: true,
              ));
          shelfAdded = true;
        });
      });
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
    return shelfAdded;
  }

  Future<bool> changeShelfName(Shelf shelf, String newShelfName) async {
    bool nameChanged = false;
    try {
      final batch = _firestore.batch();
      await _firestore.runTransaction((transaction) async {
        DocumentReference userDoc = _usersCollection.doc(uid);
        DocumentReference shelfDoc =
            userDoc.collection('shelves').doc(shelf.id);
        CollectionReference booksCollection = shelfDoc.collection('books');
        final shelfInfo = await transaction.get(shelfDoc);
        transaction.set(
            shelfDoc,
            {
              'shelf_name': newShelfName,
            },
            SetOptions(merge: true));
        transaction.set(
            userDoc,
            {
              'shelves': FieldValue.arrayRemove([shelf.shelfName]),
            },
            SetOptions(merge: true));
        transaction.set(
            userDoc,
            {
              'shelves': FieldValue.arrayUnion([newShelfName]),
            },
            SetOptions(merge: true));
        if (shelfInfo['nb_of_books'] > 0) {
          booksCollection.get().then((querySnapshot) {
            for (var doc in querySnapshot.docs) {
              batch.set(
                  doc.reference,
                  {
                    'shelf_name': newShelfName,
                  },
                  SetOptions(merge: true));
            }
            batch.commit();
          });
        }
        nameChanged = true;
      });
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
    return nameChanged;
  }

  Future<bool> deleteShelf(Shelf shelf) async {
    bool shelfDeleted = false;
    try {
      final batch = _firestore.batch();
      await _firestore.runTransaction((transaction) async {
        DocumentReference userDoc = _usersCollection.doc(uid);
        DocumentReference shelfDoc =
            userDoc.collection('shelves').doc(shelf.id);
        CollectionReference booksCollection = shelfDoc.collection('books');
        DocumentSnapshot shelfInfo = await transaction.get(shelfDoc);
        int nbOfBooks = shelfInfo['nb_of_books'];
        if (nbOfBooks > 0) {
          booksCollection.get().then((querySnapshot) {
            for (var doc in querySnapshot.docs) {
              batch.delete(doc.reference);
            }
            batch.commit();
          });
        }
        transaction.delete(shelfDoc);
        transaction.set(
            userDoc,
            {
              'nb_of_shelves': FieldValue.increment(-1),
              'shelves': FieldValue.arrayRemove([shelf.shelfName]),
              'total_books': FieldValue.increment(-nbOfBooks),
            },
            SetOptions(
              merge: true,
            ));
        _booksList
            .removeWhere((element) => element.data()['shelf_id'] == shelf.id);
        _booksController.add(_booksList);
        _shelves.removeWhere((element) => element.id == shelf.id);
        _shelvesController.add(_shelves);
        shelfDeleted = true;
      });
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
    return shelfDeleted;
  }

  Future<bool> addBook(
      Book book, Shelf shelf, XFile? _imageFile, bool kIsWeb) async {
    bool bookAdded = false;
    try {
      bool shelfExist = await checkShelf(shelf);
      DocumentReference userDoc = _usersCollection.doc(uid);
      CollectionReference shelfCollection = userDoc.collection('shelves');
      if (!shelfExist) {
        await shelfCollection.add(shelf.toFirebase()).then((doc) {
          doc.set({
                'date_added': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true,));
          userDoc.set({
                'nb_of_shelves': FieldValue.increment(1),
                'shelves': FieldValue.arrayUnion([shelf.shelfName]),
              }, SetOptions(merge: true,));
          shelf.id = doc.id;
        });
      }

      DocumentReference shelfDoc = shelfCollection.doc(shelf.id);
      CollectionReference booksCollection = shelfDoc.collection('books');
      await _firestore.runTransaction((transaction) async {
        await booksCollection.add(book.toFirebase()).then((bookDoc) {
          transaction.set(bookDoc, {
                'date_added': FieldValue.serverTimestamp(),
                'pages_read': 0,
                'rating': 0.0,
                'is_reading': false,
                'is_finished': false,
                'times_read': 0,
                'start_reading': DateTime(1000, 1, 1),
                'end_reading': DateTime(1000, 1, 1),
              }, SetOptions(merge: true));
          transaction.set(shelfDoc, {
                'nb_of_books': FieldValue.increment(1),
              }, SetOptions(merge: true,));
          transaction.set(userDoc, {
                'authors': FieldValue.arrayUnion(book.author),
                'tags': FieldValue.arrayUnion(book.tags!.toList()),
                'genre': FieldValue.arrayUnion([book.genre]),
                'publisher': FieldValue.arrayUnion([book.publisher]),
                'language': FieldValue.arrayUnion([book.language]),
                'total_books': FieldValue.increment(1),
              }, SetOptions(merge: true,));
          if (_imageFile!.path != 'no image') {
            uploadImageToFirebase(
                '${bookDoc.id}.jpg', shelf, bookDoc.id, _imageFile, kIsWeb);
          }
          bookAdded = true;
        });
      });
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
    return bookAdded;
  }

  Future<String> blurHashEncode(XFile? file) async {
    Uint8List pixels = File(file!.path).readAsBytesSync();
    String result = await blur.BlurHash.encode(pixels, 4, 3);
    return result;
  }

  Future uploadImageToFirebase(String fileName, Shelf shelf, String bookDocId,
      XFile? _imageFile, bool kIsWeb) async {
    try {
      late String blurHash = '';
      late String downloadUrl = '';
      if (kIsWeb) {
        PickedFile pickedFile = PickedFile(File(_imageFile!.path).path);
        Reference reference = FirebaseStorage.instance
            .ref()
            .child('$uid/${shelf.id}/book_covers/$fileName');
        await reference.putData(
          await pickedFile.readAsBytes(),
          SettableMetadata(contentType: 'image/jpeg'),
        );
        downloadUrl = await reference.getDownloadURL();
        blurHash = 'LUF~U0~pE34:?w%Nj]ad?HxubcWq';
      } else {
        blurHash = await blurHashEncode(_imageFile);
        TaskSnapshot snapshot = await FirebaseStorage.instance
            .ref('$uid/${shelf.id}/book_covers/$fileName')
            .putFile(File(_imageFile!.path));
        if (snapshot.state == TaskState.success) {
          downloadUrl = await snapshot.ref.getDownloadURL();
        } else {
          throw ('This file is not an image');
        }
      }
      await _usersCollection
          .doc(uid)
          .collection('shelves')
          .doc(shelf.id)
          .collection('books')
          .doc(bookDocId)
          .set({
        "cover": downloadUrl,
        'blur_hash': blurHash,
      }, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
  }

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getAllBooks() {
    try {
      var snapshots =
          _usersCollection.doc(uid).collection('shelves').snapshots();
      snapshots.forEach((snapshot) {
        for (var shelf in snapshot.docs) {
          _usersCollection
              .doc(uid)
              .collection('shelves')
              .doc(shelf.id)
              .collection('books')
              .snapshots()
              .forEach((book) {
            for (var doc in book.docs) {
              if (_booksList.where((e) => e.id == doc.id).isNotEmpty) {
                _booksList.removeWhere((element) => element.id == doc.id);
              }
              _booksList.add(doc);
              _booksController.add(_booksList);
            }
          });
        }
      });
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
    return _booksController.stream;
  }

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getShelves() {
    try {
      var snapshots =
          _usersCollection.doc(uid).collection('shelves').snapshots();
      snapshots.forEach((snapshot) {
        for (var shelf in snapshot.docs) {
          if (_shelves.where((e) => e.id == shelf.id).isNotEmpty) {
            _shelves.removeWhere((element) => element.id == shelf.id);
          }
          _shelves.add(shelf);
          _shelvesController.add(_shelves);
        }
      });
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
    return _shelvesController.stream;
  }

  Future<bool> checkIfShelfExists(String shelfId) async {
    try {
      var doc = await _usersCollection
          .doc(uid)
          .collection('shelves')
          .doc(shelfId)
          .get();
      return doc.exists;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> checkIfBookExists(String shelfId, String bookId) async {
    try {
      var doc = await _usersCollection
          .doc(uid)
          .collection('shelves')
          .doc(shelfId)
          .collection('books')
          .doc(bookId)
          .get();
      return doc.exists;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteBook(Book book) async {
    bool bookDeleted = false;
    try {
      bool bookExist = await checkIfBookExists(book.shelf!.id.toString(), book.id.toString());
      await _firestore.runTransaction((transaction) async {
        DocumentReference userDoc = _usersCollection.doc(uid);
        DocumentReference shelfDoc = userDoc.collection('shelves').doc(book.shelf!.id);
        DocumentReference bookDoc = shelfDoc.collection('books').doc(book.id);

        if(bookExist){
          transaction.delete(bookDoc);
          transaction.set(shelfDoc, {
            'nb_of_books': FieldValue.increment(-1),
          }, SetOptions(merge: true,));
          transaction.set(userDoc, {
            'total_books': FieldValue.increment(-1),
          }, SetOptions(merge: true,));
          if (book.coverUrl != "") {
            FirebaseStorage.instance
                .ref('$uid/${book.shelf!.id}/book_covers/${book.id}.jpg')
                .delete();
          }
        }
        _booksList.removeWhere((element) => element.id == book.id);
        _booksController.add(_booksList);
        bookDeleted = true;
      });
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
    return bookDeleted;
  }

  Future<bool> editBook(
      Book newBook, Shelf shelf, XFile? _imageFile, bool kIsWeb) async {
    bool bookEdited = false;
    try {
      await _firestore.runTransaction((transaction) async {
        DocumentReference userDoc = _usersCollection.doc(uid);
        DocumentReference bookDoc = userDoc.collection('shelves')
            .doc(shelf.id).collection('books').doc(newBook.id);
        transaction.set(bookDoc, newBook.toFirebase(), SetOptions(merge: true,));
        transaction.set(userDoc, {
          'authors': FieldValue.arrayUnion(newBook.author),
          'tags': FieldValue.arrayUnion(newBook.tags!.toList()),
          'genre': FieldValue.arrayUnion([newBook.genre]),
          'publisher': FieldValue.arrayUnion([newBook.publisher]),
          'language': FieldValue.arrayUnion([newBook.language]),
        }, SetOptions(merge: true,));
        if (_imageFile!.path != 'no image' &&
            _imageFile.path != 'delete image') {
          //if user took a new image
          uploadImageToFirebase(
            //upload image to firebase
              '${newBook.id}.jpg',
              shelf,
              newBook.id.toString(),
              _imageFile,
              kIsWeb);
        } else if (_imageFile.path == 'delete image') {
          // if user removed the image
          Reference ref = FirebaseStorage.instance
              .ref('$uid/${shelf.id}/book_covers/${newBook.id}.jpg');
            await ref.delete();

            transaction.set(bookDoc, {
              'cover': null,
              'blur_hash': null,
            }, SetOptions(merge: true,));
        }
        bookEdited = true;
      });
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
    return bookEdited;
  }

  Future<bool> editBookNotes(Book newBook, Shelf shelf) async {
    bool bookEdited = false;
    try {
      await _usersCollection
          .doc(uid)
          .collection('shelves')
          .doc(shelf.id)
          .collection('books')
          .doc(newBook.id.toString())
          .set(newBook.editToFirebase(), SetOptions(merge: true))
          .then((_) async {
        bookEdited = true;
      });
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
    return bookEdited;
  }

  Future<bool> deleteUserData(String uid) async {
    bool userDataDeleted = false;
    try {
      await _usersCollection.doc(uid).delete().then((_) async {
        _booksList.clear();
        _shelves.clear();
        _booksController.close();
        _shelvesController.close();
      });
      // await FirebaseStorage.instance.ref('$uid').delete();
    } on FirebaseException catch (e) {
      throw CustomException(message: e.message);
    }
    return userDataDeleted;
  }
}
