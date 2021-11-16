import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_library/models/shelf.dart';
import 'package:my_library/models/tag.dart';

class Book {
  late Shelf? shelf;
  late String title;
  final String? isbn;
  late List<dynamic> author;
  late String? isFinished,isReading;
  late String? pagesRead;
  late String? id,genre,translator, publisher, description, coverUrl, location;
  late List<dynamic>? tags;
  final String? numberOfPages;
  final String? dateAdded;
  late String? startReading;
  late String? endReading;
  final String? edition, editionDate;


  Book({this.id, required this.shelf, required this.title,
    required this.author, this.publisher, this.translator,
    required this.genre, this.tags, this.numberOfPages,
    this.dateAdded, this.location, this.isReading,
    this.coverUrl, this.description, this.isFinished, this.isbn,
    this.pagesRead, this.startReading, this.endReading,
    this.edition, this.editionDate});

  factory Book.fromFirestore(DocumentSnapshot doc){
    return Book(
      id: doc.id,
      shelf: Shelf(shelfName: doc.get('shelf')),
      title: doc.get('title'),
      author: doc.get('author'),
      genre: doc.get('genre'),
      isbn: doc.get('ISBN'),
      numberOfPages: doc.get('number_of_pages'),
      publisher: doc.get('publisher'),
      dateAdded: doc.get('date_added'),
      tags: doc.get('tags'),
      translator: doc.get('translator'),
      description: doc.get('description'),
      location: doc.get('location'),
      isFinished: doc.get('is_finished'),
      pagesRead: doc.get('pages_read'),
      isReading: doc.get('is_reading'),
      endReading: doc.get('end_reading'),
      startReading: doc.get('start_reading'),
      coverUrl: doc.get('cover'),
    );

  }

  void addTag(String tag){
    tags!.add(tag);
  }

  Shelf? getShelf(){
    return shelf;
  }

  String getTitle(){
    return title;
  }

  String? getGenre(){
    return genre;
  }
  List<dynamic>? getTags(){
    return tags;
  }

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