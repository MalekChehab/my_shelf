import 'package:flutter/material.dart';
import 'package:my_library/models/book.dart';

class BookDetails extends StatefulWidget {
  final Book book;

  BookDetails({Key? key, required this.book}) : super(key: key);

  @override
  _BookDetailsState createState() => _BookDetailsState();
}

class _BookDetailsState extends State<BookDetails> {
  late MediaQueryData queryData;
  @override
  Widget build(BuildContext context) {
    queryData = MediaQuery.of(context);
    return Scaffold(
      appBar:
      // MediaQuery.of(context).size.width < wideLayoutThreshold
      //     ?
      _buildAppBar(context),
          // : null,
      body: SingleChildScrollView(
        // physics: const BouncingScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          margin: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Flexible(
                    // fit: FlexFit.tight,
                    // flex: 3,
                    child: Hero(
                      tag: "SelectedBook-${widget.book.id}",
                      transitionOnUserGestures: true,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: widget.book.coverUrl == ""
                          ? const SizedBox(
                            child: Placeholder(),
                            height: 210,
                            width: 140,
                          ) : Image.network(
                            widget.book.coverUrl.toString(),
                            height: 210,
                            width: 140,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    // BookCover(url: _book.coverUrl),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.book.title,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        SizedBox(height: 20,),
                        Text(widget.book.author.join(', ')),
                        SizedBox(height: 20),
                        Text(
                          widget.book.genre.toString(),
                          // style: TextStyle(
                          //     color: Theme.of(context)
                          //         .textTheme
                          //         .caption!
                          //         .color!
                          //         .withOpacity(0.85),
                          //     fontFamily: 'Nunito',
                          //     fontSize: 16.0),
                        ),
                      ],
                    ),
                  ),

                  // StarRating(
                  //   starCount: 5,
                  //   rating: (_book.rating / 2).toDouble(),
                  // ),
                ],
              ),
              Divider(
                color: Colors.grey.withOpacity(0.5),
                height: 38.0,
              ),
              ],
          ),
        ),
      ),
      // body:
      // CustomScrollView(
      //   slivers: [
      //     SliverAppBar(
      //       title: Text(widget.book.title),
      //       backgroundColor: Theme.of(context).primaryColor,
      //       expandedHeight: 250,
      //       flexibleSpace: FlexibleSpaceBar(
      //         background: Hero(
      //           tag: "SelectedBook-${widget.book.id}",
      //           transitionOnUserGestures: true,
      //           child: Image.network(
      //             widget.book.coverUrl.toString(),
      //             fit: BoxFit.cover,
      //           ),
      //         ),
      //       ),
      //     ),
      //     SliverList(
      //       delegate: SliverChildListDelegate([
      //         ConstrainedBox(
      //           constraints: BoxConstraints(maxHeight: 200.0, minHeight: 200.0),
      //           child: createStoreDetails(widget.book, context),
      //         ),
      //         ConstrainedBox(
      //           constraints: BoxConstraints(maxHeight: 80.0, minHeight: 80.0),
      //           child: Padding(
      //             padding: const EdgeInsets.all(10.0),
      //             // child: showItemsButton(widget.book.id),
      //           ),
      //         ),
      //         ConstrainedBox(
      //           constraints: BoxConstraints(maxHeight: 80.0, minHeight: 80.0),
      //           child: Padding(
      //             padding: const EdgeInsets.all(10.0),
      //             // child: showBoxesButton(widget.book.id),
      //           ),
      //         ),
      //
      //       ]),
      //       // itemExtent: 200,
      //     ),
      //   ],
      // ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('Details'),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.edit,
            size: 22.0,
          ),
          onPressed: () {
            // Navigator.of(context).push(
            //   MaterialPageRoute(
            //     builder: (_) => BookAdd(book: _book),
            //   ),
            // );
          },
        ),
      ],
    );
  }

}
