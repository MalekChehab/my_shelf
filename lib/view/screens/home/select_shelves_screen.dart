import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_library/models/shelf.dart';
import 'package:my_library/services/general_providers.dart';
import 'package:my_library/view/screens/home/add_book.dart';
import 'package:my_library/view/widgets/book_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:my_library/Theme/responsive_ui.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SelectShelf extends ConsumerStatefulWidget {
  const SelectShelf({Key? key}) : super(key: key);

  @override
  SelectShelfState createState() => SelectShelfState();
}

class SelectShelfState extends ConsumerState<SelectShelf> {
  late double _height;
  late double _width;
  late double _pixelRatio;
  late bool _large;
  late bool _medium;
  final TextEditingController _newShelf = TextEditingController();
  late AsyncValue<List<String>> _shelvesList;

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    _large = ResponsiveWidget.isScreenLarge(_width, _pixelRatio);
    _medium = ResponsiveWidget.isScreenMedium(_width, _pixelRatio);
    _shelvesList = ref.watch(shelvesProvider);
    return Material(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
            ),
            onPressed: () => Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => AddBook())),
          ),
          title: const Text('Select Shelf'),
        ),
        body: Center(
          child: Column(
            children: [
              Flexible(
                child: _shelvesList.when(
                  loading: () => CircularProgressIndicator(
                    color: Theme.of(context).indicatorColor,
                  ),
                  error: (err, stack) => Center(child: Text('Error: $err')),
                  data: (shelves) {
                    return shelves.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 80, right: 10.0, left: 20),
                              child: Image.asset(
                                'assets/images/shelves.png',
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: shelves.length,
                            padding: const EdgeInsets.all(8.0),
                            itemBuilder: (context, index) {
                              return Align(
                                alignment: Alignment.center,
                                child: Container(
                                  width: _width / 1.5,
                                  padding: const EdgeInsets.all(8.0),
                                  child: Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    color: Theme.of(context).primaryColor,
                                    elevation: 4,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (_) => AddBook(
                                                  shelf: Shelf(shelfName: shelves[index]),
                                              ),
                                          ),
                                        );
                                      },
                                      child: ListTile(
                                        title: Center(
                                          child: Text(shelves[index]),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            });
                  },
                ),
              ),
              // Center(child: addShelfButton()),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add, color: Theme.of(context).accentColor),
          backgroundColor: Theme.of(context).iconTheme.color,
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    title: const Text("Add a new shelf"),
                    content: SizedBox(
                      height: _height / 4,
                      child: SingleChildScrollView(
                        child: Column(children: [
                          CustomTextFormField(
                            hint: 'Enter Shelf name',
                            textEditingController: _newShelf,
                          ),
                          SizedBox(
                            height: _height / 40,
                          ),
                          Text(
                            "*Shelf name can't be changed later",
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).hintColor
                            ),
                          ),
                          SizedBox(
                            height: _height / 40,
                          ),
                          MyButton(
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text('Add new shelf'),
                            ),
                            onPressed: () async {
                              Shelf newShelf = Shelf(shelfName: _newShelf.text);
                              Navigator.pop(context);
                              // Navigator.pop(context, newShelf);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => AddBook(shelf: newShelf)),
                              );
                            },
                          ),
                        ]),
                      ),
                    ),
                  );
                });
          },
        ),
      ),
    );
  }
}
