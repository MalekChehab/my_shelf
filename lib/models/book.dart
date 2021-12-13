import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_library/models/shelf.dart';
import 'package:my_library/models/tag.dart';

class Book {
  late Shelf? shelf;
  late String title;
  late String? isbn;
  late List<dynamic> author;
  late List<dynamic>? tags;
  late String? isFinished,isReading, pagesRead;
  late String? id,genre,translator, publisher, description, coverUrl, location;
  late String? numberOfPages, dateAdded, edition, editionDate;
  late String? startReading, endReading;


  Book({this.id, required this.shelf, required this.title,
    required this.author, this.publisher, this.translator,
    required this.genre, required this.tags, this.numberOfPages,
    this.dateAdded, this.location, this.isReading,
    this.coverUrl, this.description, this.isFinished, this.isbn,
    this.pagesRead, this.startReading, this.endReading,
    this.edition, this.editionDate});

  // factory Book.fromFirestore(DocumentSnapshot doc){
  //   return Book(
  //     id: doc.id,
  //     shelf: Shelf(shelfName: doc.get('shelf')),
  //     title: doc.get('title'),
  //     author: doc.get('author'),
  //     genre: doc.get('genre'),
  //     tags: doc.get('tags'),
  //     isbn: doc.get('ISBN'),
  //     numberOfPages: doc.get('number_of_pages'),
  //     publisher: doc.get('publisher'),
  //     translator: doc.get('translator'),
  //     edition: doc.get('edition'),
  //     editionDate: doc.get('edition_date'),
  //     location: doc.get('location'),
  //     description: doc.get('description'),
  //     pagesRead: doc.get('pages_read'),
  //     isReading: doc.get('is_reading'),
  //     isFinished: doc.get('is_finished'),
  //     dateAdded: doc.get('date_added'),
  //     startReading: doc.get('start_reading'),
  //     endReading: doc.get('end_reading'),
  //     coverUrl: doc.get('cover'),
  //   );
  //
  // }

  factory Book.fromJson(Map<String, dynamic> json){
    return Book(
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      genre: json['genre'] ?? '',
      shelf: Shelf(shelfName: json['shelf'] ?? ''),
      tags: json['tags'] ?? '',
      isbn: json['ISBN'] ?? '',
      numberOfPages: json['number_of_pages'] ?? '',
      publisher: json['publisher'] ?? '',
      translator: json['translator'] ?? '',
      edition: json['edition'] ?? '',
      editionDate: json['edition_date'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      pagesRead: json['pages_read'] ?? '',
      isReading: json['is_reading'] ?? '',
      isFinished: json['is_finished'] ?? '',
      dateAdded: json['date_added'] ?? '',
      startReading: json['start_reading'] ?? '',
      endReading: json['end_reading'] ?? '',
      coverUrl: json['cover'] ?? '',
    );
  }

  factory Book.fromFirestore(DocumentSnapshot documentSnapshot) {
    Book book = Book.fromJson(documentSnapshot.data() as Map<String, dynamic>);
    book.id = documentSnapshot.id;
    return book;
  }

  Map<String, dynamic> toFirebase() => _bookToFirebase(this);

  Map<String, dynamic> _bookToFirebase(Book book) => <String, dynamic>{
    'shelf': book.shelf!.shelfName,
    'title': book.title,
    'author': book.author,
    'genre': book.genre,
    'tags': book.tags,
    'ISBN': book.isbn,
    'number_of_pages': book.numberOfPages,
    'publisher': book.publisher,
    'translator': book.translator,
    'edition': book.edition,
    'edition_date': book.editionDate,
    'location': book.location,
    'description': book.description,
    'pages_read': book.pagesRead,
    'is_reading': book.isReading,
    'is_finished': book.isFinished,
    'date_added': DateTime.now().toString(),
    'start_reading': book.startReading,
    'end_reading': book.endReading,
    'cover': book.coverUrl,
  };

  // void addTag(String tag){
  //   tags!.add(tag);
  // }

  Shelf? getShelf(){
    return shelf;
  }

  String getTitle(){
    return title;
  }

  String? getGenre(){
    return genre;
  }
  // List<dynamic>? getTags(){
  //   return tags;
  // }

  String toString(){
    return (title);
  }

  // Book _bookDataFromSnapshot(DocumentSnapshot snapshot){
  //   return Book(
  //       shelf: shelf,
  //       title: title,
  //       author: author,
  //       genre: genre,
  //       dateAdded: dateAdded
  //   );
  // }

  // factory Book.fromDocument(DocumentSnapshot doc, Map docdata){
  //   return Book(
  //     id: doc.id,
  //     title: docdata['title'],
  //     author: docdata['author'],
  //     publisher: docdata['publisher'],
  //     genre: docdata['genre'],
  //     tags: docdata['tags'],
  //     location: docdata['location'],
  //     numberOfPages: docdata['number_of_pages'],
  //     timeStamp: docdata['timestamp'],
  //     coverUrl: docdata['cover'],
  //     description: docdata['description'],
  //   );
  // }
}