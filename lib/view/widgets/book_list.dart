import 'package:flutter/material.dart';
import 'package:my_library/models/book.dart';
import 'package:my_library/view/widgets/book_item.dart';

class BookList extends StatelessWidget {
  final List<Book> _books;

  const BookList(this._books, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double _width = MediaQuery.of(context).size.width;
    return _width <= 500
        ? ListView.separated(
      physics: const BouncingScrollPhysics(),
      separatorBuilder: ((context, index) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 22.0),
          child: Divider(
            color: Colors.grey.withOpacity(0.3),
            height: 10.0,
          ),
        );
      }),
      itemCount: _books.length,
      itemBuilder: ((context, index) {
        return BookItem(_books.elementAt(index));
      }),
    )
        : GridView.count(
        crossAxisCount: _width < 900 ? 2 : _width < 1300 ? 3 : 4 ,
      childAspectRatio: 1,
        children: List<Widget>.generate(
            _books.length, (index) => BookItem(_books.elementAt(index))
        ),
    );
  }
}
