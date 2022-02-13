import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:my_library/view/screens/home/add_book.dart';
import 'package:my_library/view/screens/home/settings_screen.dart';
import 'home_screen.dart';

class WishListScreen extends StatefulWidget {
  const WishListScreen({Key? key}) : super(key: key);

  @override
  State<WishListScreen> createState() => _WishListScreenState();
}

class _WishListScreenState extends State<WishListScreen> {
  late final bool _isLoading = false;
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
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  automaticallyImplyLeading: false,
                  actions: [
                    // IconButton(icon: const Icon(Icons.search), onPressed: () {}
                    //   //   showSearch(context: context, delegate: BookSearch());
                    //   // },
                    // ),
                    IconButton(
                      tooltip: 'Settings',
                      icon: const Icon(Icons.settings_rounded),
                      onPressed: () async {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (_) => const SettingsScreen()
                        ));
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
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40 ,right:10.0, left: 20),
                child: Image.asset(
                  'assets/images/wishlist.png',
                  // height: 25.0,
                  // fit: BoxFit.scaleDown,
                ),
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
                        pageBuilder: (c, a1, a2) => const HomeScreen(),
                        transitionsBuilder: (c, anim, a2, child) => FadeTransition(opacity: anim, child: child),
                        transitionDuration: const Duration(milliseconds: 300),
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
}
