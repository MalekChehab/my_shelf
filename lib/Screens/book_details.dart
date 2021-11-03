import 'package:flutter/material.dart';
import 'package:my_library/Models/book.dart';

class BookDetails extends StatefulWidget {
  final Book book;

  BookDetails({Key? key, required this.book}) : super(key: key);

  @override
  _StoreDetailsState createState() => _StoreDetailsState();
}

class _StoreDetailsState extends State<BookDetails> {
  late MediaQueryData queryData;
  @override
  Widget build(BuildContext context) {
    queryData = MediaQuery.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(widget.book.title),
            backgroundColor: Theme.of(context).primaryColor,
            expandedHeight: 250,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: "SelectedBook-${widget.book.id}",
                transitionOnUserGestures: true,
                child: Image.network(
                  widget.book.coverUrl.toString(),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 200.0, minHeight: 200.0),
                child: createStoreDetails(widget.book, context),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 80.0, minHeight: 80.0),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  // child: showItemsButton(widget.book.id),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 80.0, minHeight: 80.0),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  // child: showBoxesButton(widget.book.id),
                ),
              ),

            ]),
            // itemExtent: 200,
          ),
        ],
      ),
    );
  }

  Widget createStoreDetails(Book book, BuildContext context) {
    queryData = MediaQuery.of(context);
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Row(children: <Widget>[
              Icon(
                Icons.food_bank_rounded,
                color: Theme.of(context).primaryColor,
                size: 33,
              ),
              Padding(
                child: Text(
                  book.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                  textAlign: TextAlign.right,
                ),
                padding: EdgeInsets.all(10.0),
              ),
              Spacer(),
              Text(
                "rating",
                style: TextStyle(
                  fontSize: 17,
                ),
              ),
              Icon(
                Icons.star,
                color: Colors.blue,
                size: 33,
              ),
            ]),
            Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  color: Theme.of(context).primaryColor,
                  size: 33,
                ),
                Padding(
                  child: Text(
                    book.author.join(', '),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                    textAlign: TextAlign.right,
                  ),
                  padding: EdgeInsets.all(10.0),
                ),
              ],
            ),
            Row(
              children: [
                Icon(
                  Icons.phone_rounded,
                  color: Theme.of(context).primaryColor,
                  size: 33,
                ),
                // GestureDetector(
                //   onTap: () => launch('tel:${widget.book.s_phone}'),
                //   child: Padding(
                //       child: Text(
                //         store.s_phone,
                //         style: TextStyle(
                //           fontWeight: FontWeight.bold,
                //           fontSize: 17,
                //           color: Theme.of(context).accentColor,
                //         ),
                //         textAlign: TextAlign.right,
                //       ),
                //       padding: EdgeInsets.all(10.0)),
                // ),
              ],
            ),
            Row(children: [
              Icon(
                Icons.access_time_rounded,
                color: Theme.of(context).primaryColor,
                size: 33,
              ),
              // Text("Closes at:"),
              Padding(
                // child: Text(
                //   "Closes at: ${book.s_close_time}",
                //   style: TextStyle(
                //     fontWeight: FontWeight.bold,
                //     fontSize: 17,
                //   ),
                //   textAlign: TextAlign.right,
                // ),
                padding: EdgeInsets.all(10.0),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
