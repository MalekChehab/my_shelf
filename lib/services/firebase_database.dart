import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_library/models/book.dart';
import 'package:my_library/models/shelf.dart';
import 'package:my_library/services/custom_exception.dart';
import 'package:rxdart/rxdart.dart';

class FirebaseDatabase{
  FirebaseDatabase({required this.uid});
  final String uid;
  late final BehaviorSubject<List<Book>> _controller = BehaviorSubject<List<Book>>();
  late final List<Book> _bookList = [];
  late List<String> _shelves = [];
  final _service = FirebaseFirestore.instance;
  final _usersCollection = FirebaseFirestore.instance.collection('users');

  CollectionReference get userCollection => _usersCollection;

  Future<bool> addBook(Book book, Shelf shelf) async {
    bool bookAdded = false;
    try {
      await _usersCollection.doc(uid).collection(shelf.shelfName)
          .add(book.toFirebase());
    } on FirebaseException catch (e){
      throw CustomException(message: e.message);
    }
    return bookAdded;
  }

  Future<List<String>> getShelves() async{
    try{
      await _usersCollection.doc(uid).get().then((snapshot) {
        if(snapshot.data()!['shelves'] != null) {
          if (List.castFrom(snapshot.data()!['shelves']).isNotEmpty) {
            _shelves = List.castFrom(snapshot.data()!['shelves'] as List);
          }
        }
      });
    }on FirebaseException catch(e){
      throw CustomException(message: e.message);
    }
    return _shelves;
  }

  Stream<List<Book>> getAllBooks() {
    try {
       _usersCollection.doc(uid).get().then((value) {
        if (value.data()!['shelves'] != null) {
          if (List
              .castFrom(value.data()!['shelves'])
              .isNotEmpty) {
            _shelves = List.castFrom(value.data()!['shelves'] as List);
            for (String shelf in _shelves) {
              final snapshots = _usersCollection.doc(uid).collection(shelf).
                  // get()
              snapshots();
                  // .then((
                  // snapshot) {
              snapshots.forEach((snapshot){
                var docs = snapshot.docs;
                for (var doc in docs) {
                  if (doc.id != 'shelf_data') {
                    if (_bookList.where((book) => book.id == doc.id).isEmpty) {
                      _bookList.add(Book.fromFirestore(doc));
                      _controller.add(_bookList);
                    // _controller.add(Book.fromFirestore(doc));
                    }
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
      return _controller.stream;
  }

  Stream<List<Book>> get allBooks async* {
    _usersCollection.doc(uid).get().then((value) {
      if(value.data()!['shelves'] != null){
        if(List.castFrom(value.data()!['shelves']).isNotEmpty){
          _shelves = List.castFrom(value.data()!['shelves'] as List);
          for(String shelf in _shelves){
            _usersCollection.doc(uid).collection(shelf).snapshots().map((snapshot) {
              snapshot.docs.map((doc) async* {
                if(doc.id != 'shelf_data'){
                   yield Book.fromFirestore(doc);
                }
              });
            });
                // .get().then((snapshot) {
            //   var docs = snapshot.docs;
            //   for(var doc in docs) {
            //     if(doc.id != 'shelf_data') {
            //       if(_books.where((book) => book.id == doc.id).isEmpty){
            //         _books.add(Book.fromFirestore(doc));
            //         // yield Book.fromFirestore(doc);
            //       }
            //     }
            //   }
            // });
          }
        }
      }
    });
    // var stream = _usersCollection.doc(uid).collection('shelf');
    // return stream.snapshots().map((book) => book.docs.map((doc) {
    //   print(doc.id);
    //   return Book.fromFirestore(doc);
    // }).toList());
    // return null;
    // return _books;
    // .snapshots();
    // books.add(stream);
    // return stream;
    // stream.map((snapshot) => snapshot.docs.map((doc) {
    //   if(doc.id != 'shelf_data') {
    //     // return Book.fromFirestore(doc);
    //     books.add(Book.fromFirestore(doc));
    //   }
    // }).toList());
    // } on FirebaseException catch (e){
    //   throw CustomException(message: e.message.toString());
    // }
    // return isAdded;
  }
  
  // void dispose(){
  //   _controller.close();
  // }
}