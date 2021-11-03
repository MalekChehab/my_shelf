import 'package:flutter/material.dart';
import 'package:my_library/Models/book.dart';
// import 'package:provider/provider.dart';
// import 'package:book_library/src/models/notifiers/book_notifier.dart';
import 'book_item.dart';

class BookList extends StatelessWidget {
  final List<Book> _books;

  const BookList(this._books, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // var bookNotifier = Provider.of<BookNotifier>(context);

    return
        // GridView.builder(
        //   itemCount: _books.length,
        //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        //     childAspectRatio: 1.3,
        //     crossAxisCount: 2,
        //     crossAxisSpacing: 9.0,
        //     mainAxisSpacing: 9.0,
        //   ),
        //   // padding: const EdgeInsets.symmetric(horizontal: 1),
        //   itemBuilder: (BuildContext context, int index){
        //     return BookItem(_books[index]);
        //   },
        // );
        ListView.separated(
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
    // ListView.builder(
    //   itemCount: _books.length,
    //     itemBuilder: (context, index){
    //   return Align(
    //     alignment: Alignment.center,
    //     child: Container(
    //       // width: _width / 1.5,
    //       padding: const EdgeInsets.all(8.0),
    //       child: Card(
    //         shape: RoundedRectangleBorder(
    //           borderRadius: BorderRadius.circular(30),
    //         ),
    //         color: Theme
    //             .of(context)
    //             .primaryColor,
    //         elevation: 4,
    //         child: ListTile(
    //             title: Center(
    //                 child: Text(_books[index]
    //                     .getTitle()))),
    //       ),
    //     ),
    //   );
    // });
  }
}
