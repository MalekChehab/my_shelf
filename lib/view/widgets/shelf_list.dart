import 'package:flutter/material.dart';
import 'package:my_library/models/shelf.dart';
import 'package:my_library/view/widgets/shelf_item.dart';

class ShelfList extends StatelessWidget {
  final List<Shelf> _shelves;

  const ShelfList(this._shelves, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: _shelves.length,
      itemBuilder: ((context, index) {
        return ShelfItem(_shelves.elementAt(index));
      }),
    );
  }
}