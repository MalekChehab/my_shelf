import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:my_library/models/book.dart';
import 'package:my_library/services/auth_service.dart';
import 'package:my_library/services/general_providers.dart';
import 'package:my_library/view/screens/home/add_book.dart';
import 'package:my_library/view/screens/home/settings_screen.dart';
import 'package:my_library/view/screens/home/wish_list_screen.dart';
import 'package:my_library/view/widgets/book_list.dart';


class BookSearch extends SearchDelegate<String> {

  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(
      icon: const Icon(Icons.clear),
      onPressed: () {
        if (query.isEmpty) {
          Navigator.of(context).pop();
        } else {
          query = '';
          showSuggestions(context);
        }
      },
    )
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => Navigator.of(context).pop(),
  );

  @override
  Widget buildResults(BuildContext context) => Center(
    child: HookConsumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final results = ref.watch(allBooksProvider).asData;
        return BookList(results!.value.where((book) =>
        book.title.contains(query)
            || book.title.toLowerCase().contains(query)
            || book.author.any(
                (author) => author.contains(query) || author.toLowerCase().contains(query))
        ).toList());
      },
    ),
  );

  @override
  Widget buildSuggestions(BuildContext context) {
    return HookConsumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        final results = ref.watch(allBooksProvider).asData;
        if(query.isNotEmpty) {
          return BookList(results!.value.where((book) =>
          book.title.contains(query)
              || book.title.toLowerCase().contains(query)
              || book.author.any(
                  (author) => author.contains(query) || author.toLowerCase().contains(query))
          ).toList());
        }
        return BookList(results!.value);
      },
    );
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends ConsumerState<HomeScreen> {
  late final bool _isLoading = false;
  late AsyncValue<List<Book>> _booksList;
  late AuthenticationService _auth;

  @override
  Widget build(BuildContext context) {
    _auth = ref.watch(authServicesProvider);
    _booksList = ref.watch(allBooksProvider);
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
                    IconButton(icon: const Icon(Icons.search), onPressed: () {
                          showSearch(context: context, delegate: BookSearch());
                        },
                        ),
                    IconButton(
                      tooltip: 'Settings',
                      icon: const Icon(Icons.settings_rounded),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SettingsScreen()));
                      },
                    ),
                  ],
                  titleTextStyle: Theme.of(context).textTheme.bodyText1,
                  backgroundColor: Theme.of(context).primaryColor,
                  elevation: 20,
                  title: Text(_auth.userExist()
                      ? _auth.getUserName().toString().endsWith('s') || _auth.getUserName().toString().endsWith('S')
                      ? _auth.getUserName().toString() + "' Shelf"
                      : _auth.getUserName().toString() + "'s Shelf"
                      : 'My Shelf'),
                  pinned: true,
                  floating: true,
                ),
              ];
            },
            body: Column(
              children: [
                _booksList.value != null
                    ? _booksList.value!.isNotEmpty
                        ? Text(_auth.userExist()
                            ? _auth.getUserName().toString()
                            : '')
                        : const SizedBox()
                    : const SizedBox(),
                Expanded(
                  child: Center(
                    child: _booksList.when(
                      loading: () {
                        return CircularProgressIndicator(
                          color: Theme.of(context).indicatorColor,
                        );
                      },
                      error: (err, stack) {
                        return Center(child: Text('Error: $err'));
                      },
                      data: (books) {
                        return Center(
                          child: books.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 40,
                                    right: 10.0,
                                    left: 20,
                                  ),
                                  child: Image.asset(
                                    'assets/images/home.png',
                                  ),
                                )
                              : BookList(books),
                        );
                      },
                    ),
                  ),
                ),
              ],
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
                        context,
                        PageRouteBuilder(
                          pageBuilder: (c, a1, a2) => const WishListScreen(),
                          transitionsBuilder: (c, anim, a2, child) =>
                              FadeTransition(opacity: anim, child: child),
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
