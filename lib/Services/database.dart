import 'package:my_library/models/book.dart';
import 'package:my_library/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {

  final String uid;
  DatabaseService({ required this.uid });

  // collection reference
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');

  Future<void> updateUserData(String name, int nbOfBooks, List<String> shelves) async {
    return await userCollection.doc(uid).set({
      'name': name,
      'total_books': nbOfBooks,
      'shelves': shelves
    });
  }

  // book list from snapshot
  // List<Book> _bookListFromSnapshot(QuerySnapshot snapshot) {
  //   // return snapshot.docs.map((doc){
  //     //print(doc.data);
  //   return StreamProvider
  //     return Book(
  //       title: doc.data['title'],
  //         name: doc.data['name'] ?? '',
  //         strength: doc.data['strength'] ?? 0,
  //         sugars: doc.data['sugars'] ?? '0'
  //     );
  //   }).toList();
  // }

  // user data from snapshots
  // UserData _userDataFromSnapshot(DocumentSnapshot snapshot) {
  //   return UserData(
  //       uid: uid,
  //       name: snapshot.data['name'],
  //       sugars: snapshot.data['sugars'],
  //       strength: snapshot.data['strength']
  //   );
  // }
  //
  // // get brews stream
  // Stream<List<Brew>> get brews {
  //   return brewCollection.snapshots()
  //       .map(_brewListFromSnapshot);
  // }
  //
  // // get user doc stream
  // Stream<UserData> get userData {
  //   return brewCollection.document(uid).snapshots()
  //       .map(_userDataFromSnapshot);
  // }

}