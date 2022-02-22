import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_library/models/shelf.dart';

class Book {
  late Shelf? shelf;
  late String title;
  late List<dynamic> author;
  late int numberOfPages;
  late List<dynamic>? tags;
  late String? id,genre,translator, publisher, description, coverUrl, blurHash, location;
  late String? isbn, edition, editionDate, language, publishDate;
  late bool? isFinished,isReading;
  late int? pagesRead, timesRead;
  late double? rating;
  late DateTime? startReading, endReading;
  late DateTime? dateAdded;


  Book({this.id, this.shelf, required this.title,
    required this.author,required this.numberOfPages, this.publisher, this.translator,
    this.genre, this.tags, this.timesRead, this.blurHash,
    this.dateAdded, this.location, this.isReading,
    this.coverUrl, this.description, this.isFinished, this.isbn,
    this.pagesRead, this.startReading, this.endReading, this.rating,
    this.edition, this.editionDate, this.language, this.publishDate});

  factory Book.fromJson(Map<String, dynamic> json){
    return Book(
      shelf: Shelf(shelfName: json['shelf_name'], id: json['shelf_id']),
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      genre: json['genre'] ?? '',
      numberOfPages: int.parse(json['number_of_pages'].toString()),
      location: json['location'] ?? '',
      tags: json['tags'] ?? '',
      translator: json['translator'] ?? '',
      publisher: json['publisher'] ?? '',
      publishDate: json['publish_date'],
      isbn: json['ISBN'] ?? '',
      language: json['language'] ?? '',
      description: json['description'] ?? '',
      edition: json['edition'] ?? '',
      editionDate: json['edition_date'] ?? '',
      coverUrl: json['cover'] ?? '',
      blurHash: json['blur_hash'],
      pagesRead: int.parse(json['pages_read'].toString()),
      isReading: json['is_reading'].toString() == 'true',
      isFinished: json['is_finished'].toString() == 'true',
      dateAdded: DateTime.parse(json['date_added'].toDate().toString()),
      startReading: DateTime.parse(json['start_reading'].toDate().toString()),
      endReading: DateTime.parse(json['end_reading'].toDate().toString()),
      rating: double.parse(json['rating'].toString()),
      timesRead: int.parse(json['times_read'].toString()),
    );
  }

  factory Book.fromFirestore(DocumentSnapshot documentSnapshot) {
    Book book = Book.fromJson(documentSnapshot.data() as Map<String, dynamic>);
    book.id = documentSnapshot.id;
    return book;
  }

  Map<String, dynamic> toFirebase() => _bookToFirebase(this);

  Map<String, dynamic> _bookToFirebase(Book book) => <String, dynamic>{
    'shelf_name': book.shelf!.shelfName,
    'shelf_id': book.shelf!.id,
    'title': book.title,
    'author': book.author,
    'genre': book.genre,
    'location': book.location,
    'tags': book.tags,
    'translator': book.translator,
    'publisher': book.publisher,
    'publish_date': book.publishDate,
    'ISBN': book.isbn,
    'number_of_pages': book.numberOfPages,
    'language': book.language,
    'description': book.description,
    'edition': book.edition,
    'edition_date': book.editionDate,
  };

  Map<String, dynamic> editToFirebase() => _editBookToFirebase(this);

  Map<String, dynamic> _editBookToFirebase(Book book) => <String, dynamic>{
    'pages_read': book.pagesRead,
    'is_reading': book.isReading,
    'is_finished': book.isFinished,
    'start_reading': book.startReading,
    'end_reading': book.endReading,
    'rating': book.rating,
    'times_read': book.timesRead,
  };

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
}