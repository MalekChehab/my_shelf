import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:my_library/Models/book.dart';
import 'package:my_library/Models/shelf.dart';
import 'package:my_library/Screens/Authentication/welcome_screen.dart';
import 'package:my_library/Screens/add_book.dart';
import 'package:my_library/Widgets/book_item.dart';
import 'package:my_library/Widgets/book_list.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'home_screen.dart';

class WishListScreen extends StatefulWidget {
  const WishListScreen({Key? key}) : super(key: key);

  @override
  State<WishListScreen> createState() => _WishListScreenState();
}

class _WishListScreenState extends State<WishListScreen> {
  late bool _isLoading = false;
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final usersCollection = FirebaseFirestore.instance.collection('users');
  late List<String> shelvesStrings = [];
  final List<Book> finalBooksList = [];
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        body: LoadingOverlay(
          isLoading: _isLoading,
          progressIndicator: CircularProgressIndicator(
            color: Theme.of(context).indicatorColor,
          ),
          child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(icon: const Icon(Icons.search), onPressed: () {}
                      //   showSearch(context: context, delegate: BookSearch());
                      // },
                    ),
                    IconButton(
                      tooltip: 'Settings',
                      icon: const Icon(Icons.settings_rounded),
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });
                        Future.delayed(const Duration(seconds: 2), () async {
                          await GoogleSignIn().signOut();
                          await FirebaseAuth.instance.signOut().then((value) {
                            setState(() {
                              _isLoading = false;
                            });
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => WelcomeScreen()),
                                    (route) => false);
                          });
                        });
                      },
                    ),
                  ],
                  titleTextStyle: Theme.of(context).textTheme.bodyText1,
                  backgroundColor: Theme.of(context).primaryColor,
                  elevation: 12,
                  title: const Text('My Wish List'),
                  pinned: true,
                  floating: true,
                ),
              ];
            },
            body: Center(
              // child: StreamBuilder(
              //   stream: shelvesList(),
              //   // test(),
              //   builder: (context, snapshot) {
              //     if (snapshot.connectionState == ConnectionState.waiting) {
              //       return CircularProgressIndicator(
              //         color: Theme.of(context).indicatorColor,
              //       );
              //     } else if (snapshot.hasError) {
              //       return Text(snapshot.error.toString());
              //     }
              //     return BookList(finalBooksList);
              //   },
              // ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: "Add Book",
          child: Icon(Icons.add, color: Theme.of(context).accentColor),
          backgroundColor: Theme.of(context).iconTheme.color,
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => AddBook()));
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomAppBar(
            color: Theme.of(context).primaryColor,
            elevation: 12,
            shape: const CircularNotchedRectangle(),
            child: SizedBox(
              height: 56,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  TextButton.icon(
                    icon: Icon(
                        Icons.import_contacts_rounded,
                        color: Theme.of(context).accentColor,
                    ),
                    label: Text(
                        "My Shelf",
                        style: TextStyle(
                            color: Theme.of(context).accentColor,
                        ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                          context, PageRouteBuilder(
                        pageBuilder: (c, a1, a2) => HomeScreen(),
                        transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                        transitionDuration: Duration(milliseconds: 300),
                      ),);
                    },
                  ),
                  const SizedBox(width: 40), // The dummy child
                  IconButton(
                      icon: const Icon(
                        Icons.favorite_rounded,
                      ),
                      tooltip: "Wish List",
                      onPressed: () {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(
                            builder: (BuildContext context) => super.widget),

                        );
                      }
                  ),
                ],
              ),
            )),
      ),
    );
  }

  shelvesList() {
    Stream<Object> snap;
    usersCollection.doc(uid).get().then((value) {
      shelvesStrings = List.castFrom(value.data()!['shelves'] as List);
      for (String shelf in shelvesStrings) {
        usersCollection.doc(uid).collection(shelf).get().then((value) {
          createBookList(value);
        });
      }
    });
    print('${finalBooksList.length} books');
    print('${shelvesStrings.length} shelves');
  }

  createBookList(QuerySnapshot snapshot) async {
    var docs = snapshot.docs;
    for (var doc in docs) {
      if (finalBooksList.where((book) => book.id == doc.id).isEmpty) {
        setState(() {
          finalBooksList.add(Book.fromFirestore(doc));
        });
      }
    }
  }
}

// class BookSearch extends SearchDelegate<Book> {
//   @override
//   ThemeData appBarTheme(BuildContext context) {
//     return Theme.of(context);
//   }
//
//   @override
//   List<Widget> buildActions(BuildContext context) {
//     return [
//       IconButton(
//         icon: Icon(Icons.clear),
//         color: Theme.of(context).iconTheme.color,
//         onPressed: () => query = '',
//       )
//     ];
//   }
//
//   @override
//   Widget buildLeading(BuildContext context) {
//     return IconButton(
//       icon: Icon(Icons.arrow_back),
//       color: Theme.of(context).iconTheme.color,
//       onPressed: () => Navigator.of(context).pop(),
//     );
//   }
//
//   @override
//   Widget buildResults(BuildContext context) {
//     final books = Provider.of<BookNotifier>(context).books;
//
//     final results = books
//         .where((book) =>
//     book.title.toLowerCase().contains(query) ||
//         book.author.toLowerCase().contains(query))
//         .toList();
//
//     return BookList(books: results);
//   }
//
//   @override
//   Widget buildSuggestions(BuildContext context) {
//     final books = Provider.of<BookNotifier>(context).books;
//
//     final results = books
//         .where((book) =>
//     book.title.toLowerCase().contains(query) ||
//         book.author.toLowerCase().contains(query))
//         .toList();
//
//     return BookList(books: results);
//   }
// }
