import 'package:flutter/material.dart';
import 'package:my_library/models/book.dart';
// import 'package:provider/provider.dart';
// import 'package:book_library/src/models/notifiers/book_notifier.dart';
import 'package:my_library/view/widgets/book_item.dart';

class BookList extends StatelessWidget {
  final List<Book> _books;

  const BookList(this._books, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return ListView.separated(
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
    );
  }
}
