import 'package:cloud_firestore/cloud_firestore.dart';
import 'book.dart';

class Shelf {
  late String? id;
  late final List<Book> books;
  late final String shelfName;
  late final int numberOfBooks;

  Shelf({required this.shelfName, this.id});

  Map<String, dynamic> toFirebase() => _shelfToFirebase(this);

  Map<String, dynamic> _shelfToFirebase(Shelf shelf) => <String, dynamic>{
    'shelf_name': shelfName,
    'nb_of_books': 0,
  };

  factory Shelf.fromFirestore(DocumentSnapshot documentSnapshot) {
    Shelf shelf = Shelf.fromJson(documentSnapshot.data() as Map<String, dynamic>);
    shelf.id = documentSnapshot.id;
    return shelf;
  }

  factory Shelf.fromJson(Map<String, dynamic> json){
    return Shelf(
      shelfName: json['shelf_name'],
    );
  }

  void setShelfName(String newName){
    shelfName = newName;
  }

  void addBook(Book book){
    books.add(book);
    numberOfBooks++;
  }

  void removeBook(Book book){
    books.remove(book);
    numberOfBooks--;
  }

  String getShelfName(){
    return shelfName;
  }

  List<Book> getBookList(){
    return books;
  }

  int getNumberOfBooks(){
    return numberOfBooks;
  }
}