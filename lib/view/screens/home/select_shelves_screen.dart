import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:my_library/models/shelf.dart';
import 'package:my_library/models/user.dart';
import 'package:my_library/view/screens/home/add_book.dart';
import 'package:my_library/view/widgets/book_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:my_library/Theme/responsive_ui.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SelectShelf extends StatefulWidget {
  SelectShelf({Key? key}) : super(key: key);

  @override
  State<SelectShelf> createState() => _SelectShelfState();
}

class _SelectShelfState extends State<SelectShelf> {
  late double _height;
  late double _width;
  late double _pixelRatio;
  late bool _large;
  late bool _medium;
  final TextEditingController _newShelf = TextEditingController();
  final uid = FirebaseAuth.instance.currentUser!.uid;
  late List<Shelf> _shelves = [];
  CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    _large = ResponsiveWidget.isScreenLarge(_width, _pixelRatio);
    _medium = ResponsiveWidget.isScreenMedium(_width, _pixelRatio);

    return Material(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back,),
            onPressed: () => Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => AddBook())),
          ),
          title: const Text('Select Shelf'),
        ),
        body: Center(
          child: Column(
            children: [
              Flexible(
                child: StreamBuilder<DocumentSnapshot>(
                  //streambuilder listens to document which is each user
                  stream: usersCollection.doc(uid).snapshots(),
                  builder: (context, snapshot) {
                    try {
                      //if there is data
                      if (snapshot.hasData) {
                        if(snapshot.data!.get('shelves')==null){
                          return const Text("You don't have any shelf, please add a shelf");
                        }else {
                          //put the data of the field 'shelves' in a list
                          List<dynamic> snapshots = snapshot.data!.get('shelves');
                          //loop the list to add each element to a list of Shelf
                          snapshots.forEach((element) {
                            //check if the list _shelves has duplicate
                            if (_shelves.where((shelf) =>
                            shelf.getShelfName() == element.toString())
                                .isEmpty) {
                              _shelves.add(
                                  Shelf(shelfName: element.toString()));
                              //now we have a list of Shelf consists of the 'shelves' field in each document
                            }
                          });
                          return _shelves.isEmpty ?  Center(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 40 ,right:10.0, left: 20),
                              child: Image.asset(
                                'assets/images/shelves.png',
                                // height: 25.0,
                                // fit: BoxFit.scaleDown,
                              ),
                            ),
                          ) :
                          ListView.builder(
                              itemCount: _shelves.length,
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
                                      color: Theme
                                          .of(context)
                                          .primaryColor,
                                      elevation: 4,
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (_) =>
                                                    AddBook(
                                                        shelf: _shelves[index])),
                                          );
                                        },
                                        child: ListTile(
                                            title: Center(
                                                child: Text(_shelves[index]
                                                    .getShelfName()))),
                                      ),
                                    ),
                                  ),
                                );
                              });
                        }
                      } else if (snapshot.hasError) {
                        return Text(snapshot.hasError.toString());
                      } else {
                        return const CircularProgressIndicator();
                      }
                    } catch(e){
                      if(e.toString()=='Bad state: field does not exist within the DocumentSnapshotPlatform'){
                        return const Center(
                            child: Text("You don't have any shelves, please add a shelf")
                        );
                      }else{
                        return Center(
                          child: Text(e.toString()),
                        );
                      }
                    }
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
                      height: _height / 5,
                      child: SingleChildScrollView(
                        child: Column(
                            children: [
                              CustomTextFormField(
                                hint: 'Enter Shelf name',
                                textEditingController: _newShelf,
                              ),
                              SizedBox(
                                height: _height / 30,
                              ),
                              Button(
                                child: const Padding(
                                  padding:  EdgeInsets.all(8.0),
                                  child: Text('Add new shelf'),
                                ),
                                onPressed: () async {
                                  Shelf newShelf = Shelf(shelfName: _newShelf.text);
                                  Navigator.pop(context);
                                  // Navigator.pop(context, newShelf);
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => AddBook(shelf: newShelf)
                                    ),
                                  );
                                },
                              ),
                            ]
                        ),
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
