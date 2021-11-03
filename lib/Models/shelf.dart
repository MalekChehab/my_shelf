import 'package:flutter/cupertino.dart';

import 'book.dart';

class Shelf {
  late String id;
  late final List<Book> books;
  late final String shelfName;
  late final int numberOfBooks;

  Shelf({required this.shelfName}){
    books = List.empty();
    numberOfBooks = 0;
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