import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  late final BehaviorSubject<List<QueryDocumentSnapshot<Map<String, dynamic>>>> _controller =
  BehaviorSubject<List<QueryDocumentSnapshot<Map<String, dynamic>>>>();
  late List<QueryDocumentSnapshot<Map<String, dynamic>>> list = [];
  late List<QueryDocumentSnapshot<Map<String, dynamic>>> docs = [];

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

  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getAllBooks() {
    try {
      _usersCollection.doc(uid).get().then((value) {
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
                    if(list.where((book) => book.id == doc.id).isNotEmpty) {
                      list.removeWhere((element) => element.id == doc.id);
                    }
                    list.add(doc);
                    _controller.add(list);
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
}