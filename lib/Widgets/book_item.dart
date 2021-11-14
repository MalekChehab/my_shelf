import 'package:flutter/material.dart';

import 'package:my_library/Models/book.dart';
import 'package:my_library/Screens/add_book.dart';
import 'package:my_library/Screens/book_details.dart';
// import 'package:book_library/src/models/notifiers/book_notifier.dart';
// import 'package:book_library/src/widgets/book_cover.dart';
// import 'package:book_library/src/widgets/star_rating.dart';
// import 'package:book_library/src/screens/book/book_details.dart';
// import 'package:book_library/src/style.dart';

class BookItem extends StatelessWidget {
  final Book _book;

  const BookItem(this._book, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => BookDetails(book: _book)));
        // if (MediaQuery.of(context).size.width > wideLayoutThreshold) {
        //   bookNotifier.selectedIndex = bookNotifier.books.indexOf(_book);
        // } else {
        //   Navigator.push(
        //       context, MaterialPageRoute(builder: (_) => BookDetails(_book)));
        // }
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(20.0, 8, 20, 10),
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
        height: 180.0,
        child: Row(
          children: [
            Flexible(
              fit: FlexFit.tight,
              flex: 4,
              child: Hero(
                tag: "SelectedBook-${_book.id}",
                transitionOnUserGestures: true,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: _book.coverUrl == "" ? const Placeholder()
                        : Image.network(
                      _book.coverUrl.toString(),
                      // height: 170,
                      // width: 500,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              // BookCover(url: _book.coverUrl),
            ),
            Flexible(
              flex: 6,
              child: Container(
                // decoration:
                // BoxDecoration(
                //   border: Border(
                //     right: BorderSide(
                //       width: 4.0,
                //       color: Theme.of(context).accentColor,
                //     ),
                //   ),
                // ),
                padding: const EdgeInsets.fromLTRB(15.0, 1.0, 0.0, 1.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _book.title,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            _book.author.join(", "),
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ),
                      ],
                    ),
                    // StarRating(
                    //   starCount: 5,
                    //   rating: (_book.rating / 2).toDouble(),
                    // ),
                    Text(
                      _book.genre.toString(),
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: IntrinsicHeight(
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                _book.shelf!.shelfName,
                                style: Theme.of(context).textTheme.caption,
                              ),
                            ),
                            VerticalDivider(
                              color: Theme.of(context).accentColor,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 10.0),
                              child: Text(
                                _book.location.toString(),
                                style: TextStyle(
                                    color: Theme.of(context).hintColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
