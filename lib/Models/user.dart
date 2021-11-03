import 'package:my_library/Models/shelf.dart';

class MyUser{

  final String id;
  final String name;
  late List<Shelf> shelves;
  late int numberOfShelves = shelves.length;
  late int? totalBooks;

  MyUser({required this.id, required this.name, this.totalBooks}){
    shelves = List.empty();
    totalBooks = 0;
  }

  void addShelf(Shelf shelf){
    shelves.add(shelf);
    numberOfShelves++;
  }

  void removeShelf(Shelf shelf){
    shelves.remove(shelf);
    numberOfShelves--;
  }

  void setTotalBooks(int totalBooks){
    this.totalBooks = totalBooks;
  }

  String getId(){
    return id;
  }

  String getName(){
    return name;
  }

  List<Shelf> getShelves(){
    return shelves;
  }

  int? getTotalBooks(){
    return totalBooks;
  }

}