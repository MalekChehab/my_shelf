import 'package:flutter/material.dart';
import 'package:my_library/models/book.dart';
import 'package:my_library/view/screens/home/book_details.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:octo_image/octo_image.dart';

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
              child: Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child:
                  _book.coverUrl == "" ? const Placeholder()
                      :
                  // FadeInImage.memoryNetwork(
                  //   placeholder: kTransparentImage,
                  //   image: _book!.coverUrl.toString(),
                  //   fit: BoxFit.cover,
                  // ),
                  // CachedNetworkImage(
                  //   imageUrl: _book.coverUrl.toString(),
                  //   fit: BoxFit.cover,
                  //   placeholder: (context, url) => Image.asset('assets/images/home.png'),
                  // ),
                  AspectRatio(
                    aspectRatio: 0.6,
                    child: OctoImage(
                      image: CachedNetworkImageProvider(
                          _book.coverUrl.toString()
                      ),
                      placeholderBuilder: OctoPlaceholder.blurHash(_book.blurHash.toString()),
                      errorBuilder: OctoError.icon(color: Colors.red),
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
                          style: Theme.of(context).textTheme.headline3,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            _book.author.join(', '),
                            style: Theme.of(context).textTheme.caption,
                          ),
                        ),
                      ],
                    ),
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
