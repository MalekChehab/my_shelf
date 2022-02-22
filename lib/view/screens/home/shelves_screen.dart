import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:my_library/models/shelf.dart';
import 'package:my_library/services/custom_exception.dart';
import 'package:my_library/services/general_providers.dart';
import 'package:my_library/view/screens/home/add_book.dart';
import 'package:my_library/view/widgets/book_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:my_library/controllers/responsive_ui.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_library/view/widgets/dialog.dart';
import 'package:my_library/view/widgets/shelf_list.dart';

class ShelvesScreen extends ConsumerStatefulWidget {
  const ShelvesScreen({Key? key}) : super(key: key);

  @override
  ShelvesScreenState createState() => ShelvesScreenState();
}

class ShelvesScreenState extends ConsumerState<ShelvesScreen> {
  late double _height;
  late double _width;
  late double _pixelRatio;
  late bool _large;
  late bool _medium;
  late dynamic _db;
  late AsyncValue<List<Shelf>> _shelvesProvider;
  late List<Shelf> _shelvesList;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    _large = ResponsiveWidget.isScreenLarge(_width, _pixelRatio);
    _medium = ResponsiveWidget.isScreenMedium(_width, _pixelRatio);
    _db = ref.watch(firebaseDatabaseProvider);
    _shelvesProvider = ref.watch(shelvesProvider);
    return Material(
      child: LoadingOverlay(
        // isLoading: _isLoading,
        isLoading: ref.watch(loadingProvider.state).state,
        progressIndicator: CircularProgressIndicator(
          color: Theme.of(context).indicatorColor,
        ),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Manage Shelves'),
          ),
          body: Center(
            child: _shelvesProvider.when(
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
                    : ShelfList(shelves);
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add, color: Theme.of(context).accentColor),
            backgroundColor: Theme.of(context).iconTheme.color,
            onPressed: () {
              addNewShelf();
            },
          ),
        ),
      ),
    );
  }

  addNewShelf(){
    _shelvesList = _shelvesProvider.asData!.value;
    TextEditingController _newShelf =
    TextEditingController();
    showDialog(
        context: context,
        builder: (_) {
          return MyDialog(
            buttonLabel: 'Add',
            onPressed: () async {
              if(_shelvesList.any((element) => element.shelfName == _newShelf.text)) {
                showToast('Shelf already exist');
              }else {
                Navigator.of(context).pop();
                // setState(() {
                //   _isLoading = true;
                // });
                try {
                  bool shelfAdded = await _db.addShelf(
                      Shelf(shelfName: _newShelf.text));
                  if(shelfAdded){
                    ref.refresh(shelvesProvider);
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => super.widget));
                    // ScaffoldMessenger.of(context).showMaterialBanner(
                    //   MaterialBanner(
                    //     backgroundColor: Theme.of(context).buttonColor,
                    //     content: Text(
                    //         'Shelf ${_newShelf.text} has been added'),
                    //     actions: [
                    //       TextButton(
                    //         child: const Text('Dismiss'),
                    //         onPressed: () => ScaffoldMessenger.of(context)
                    //             .hideCurrentMaterialBanner(),
                    //       ),
                    //     ],
                    //   ),
                    // );
                    // Future.delayed(const Duration(seconds: 2), () {
                    //   setState(() {
                    //     _isLoading = false;
                    //   // });
                    // });
                  }
                } on CustomException catch (e){
                  // setState(() {
                  //   _isLoading = false;
                  // });
                  showToast(e.message.toString());
                }
              }
            },
            title: 'Add new shelf',
            textField1:
            CustomTextFormField(
              capitalization:
              TextCapitalization
                  .words,
              icon: Icons
                  .house_siding_rounded,
              hint: 'Enter Shelf Name',
              textEditingController:
              _newShelf,
            ),
          );
        });
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: Theme.of(context).iconTheme.color,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
