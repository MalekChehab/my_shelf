import 'package:flutter/material.dart';
import 'package:my_library/models/shelf.dart';
import 'package:my_library/view/screens/home/add_book.dart';

class ShelfItem extends StatelessWidget {
  final Shelf _shelf;
  late double _height;
  late double _width;

  ShelfItem(this._shelf, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: _width / 1.5,
        padding: const EdgeInsets.all(8.0),
        child: Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
              side: BorderSide(color: Theme.of(context).backgroundColor)),
          color: Theme.of(context).primaryColor,
          elevation: 8,
          child: InkWell(
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => AddBook(shelf: _shelf)));
            },
            child: ListTile(
              title: Center(
                child: Text(_shelf.shelfName),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
