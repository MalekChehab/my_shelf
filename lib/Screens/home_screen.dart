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
import 'package:my_library/Screens/wish_list_screen.dart';
import 'package:my_library/Widgets/book_item.dart';
import 'package:my_library/Widgets/book_list.dart';
import 'package:google_sign_in/google_sign_in.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
                  elevation: 20,
                  title: const Text('My Shelf'),
                  pinned: true,
                  floating: true,
                ),
              ];
            },
            body: Center(
              child: FutureBuilder(
                future: shelvesList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(
                      color: Theme.of(context).indicatorColor,
                    );
                  } else if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }
                  return BookList(finalBooksList);
                },
              ),
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
                  IconButton(
                    icon: const Icon(
                      Icons.menu_book_rounded,
                      // color: Theme.of(context).accentColor,
                    ),
                    tooltip: "My Shelf",
                    onPressed: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (BuildContext context) => super.widget));
                    },
                  ),
                  const SizedBox(width: 40), // The dummy child
                  TextButton.icon(
                    icon: Icon(
                      Icons.favorite_outline_rounded,
                      color: Theme.of(context).accentColor,
                    ),
                    label: Text(
                        "Wish List",
                        style: TextStyle(
                            color: Theme.of(context).accentColor,
                        ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context, PageRouteBuilder(
                        pageBuilder: (c, a1, a2) => WishListScreen(),
                        transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                        transitionDuration: Duration(milliseconds: 300),
                      ),);
                    },
                  ),
                ],
              ),
            )),
      ),
    );
  }

  shelvesList() {
    usersCollection.doc(uid).get().then((value) {
      if(value.id != 'shelf_data') {
        if(List.castFrom(value.data()!['shelves']).isNotEmpty) {
          shelvesStrings = List.castFrom(value.data()!['shelves'] as List);
          for (String shelf in shelvesStrings) {
            usersCollection.doc(uid).collection(shelf).get().then((value) {
              createBookList(value);
            });
          }
        }
      }
    });
    print('${finalBooksList.length} books');
    print('${shelvesStrings.length} shelves');
  }

  createBookList(QuerySnapshot snapshot) async {
    var docs = snapshot.docs;
    for (var doc in docs) {
      if(doc.id!='shelf_data') {
        if (finalBooksList
            .where((book) => book.id == doc.id)
            .isEmpty) {
          setState(() {
            finalBooksList.add(Book.fromFirestore(doc));
          });
        }
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
