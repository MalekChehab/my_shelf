import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_library/models/shelf.dart';
import 'package:my_library/view/widgets/book_text_form_field.dart';
import '../../services/custom_exception.dart';
import '../../services/general_providers.dart';
import 'dialog.dart';
import 'package:intl/intl.dart' as intl;

class ShelfItem extends ConsumerStatefulWidget {
  final Shelf _shelf;

  const ShelfItem(this._shelf, {Key? key}) : super(key: key);

  @override
  ShelfItemState createState() => ShelfItemState();
}

class ShelfItemState extends ConsumerState<ShelfItem> {
  late double _height;
  late double _width;
  late dynamic _db;
  late AsyncValue<List<Shelf>> _shelvesProvider;
  late List<Shelf> _shelvesList;

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _db = ref.watch(firebaseDatabaseProvider);
    _shelvesProvider = ref.watch(shelvesProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20,10,20,10),
      child: Container(
        height: _height / 6,
        width: _width / 1.2,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10.0,
              offset: Offset(0.0, 10.0),
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.only(left:30, top: 12,),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: [
                  Text(
                    widget._shelf.shelfName,
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    iconSize: 18,
                    color: Theme.of(context).iconTheme.color,
                    elevation: 20,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        height: 30,
                        value: 'edit',
                        child: SizedBox(
                          width: 130,
                          child: Row(children: [
                            Icon(
                              Icons.edit_rounded,
                              color: Theme.of(context).primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Edit name',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 16,
                              ),
                            ),
                          ]),
                        ),
                      ),
                      PopupMenuItem(
                        height: 30,
                        value: 'delete',
                        child: SizedBox(
                          width: 120,
                          child: Row(children: [
                            Icon(
                              Icons.delete_rounded,
                              color: Theme.of(context).primaryColor,
                              size: 20,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Delete Shelf',
                              style: TextStyle(color: Theme.of(context).primaryColor,
                              fontSize: 16,
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          editShelfName();
                          break;
                        case 'delete':
                          deleteShelf();
                          break;
                      }
                    },
                  ),
                ],
              ),
              Container(
                  height: 2.0,
                  width: 80,
                  color: const Color(0xff00c6ff)),
              const SizedBox(height: 12,),
              Row(
                children: <Widget>[
                  Text(
                    'Number of Books: ${widget._shelf.numberOfBooks.toString()}',
                    style: TextStyle(fontSize: 13, color: Theme.of(context).buttonColor),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      'Created at: ${intl.DateFormat('dd MMM yyyy').format(widget._shelf.dateAdded!)}',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  editShelfName(){
    _shelvesList = _shelvesProvider.asData!.value;
    TextEditingController _newShelfName =
    TextEditingController(text: widget._shelf.shelfName);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return MyDialog(
            buttonLabel: 'Save',
            onPressed: () async {
              if(_shelvesList.any((element) => element.shelfName == _newShelfName.text)) {
                showToast('Shelf already exist');
              }else {
                try{
                  bool shelfNameChanged = await _db.changeShelfName(widget._shelf, _newShelfName.text);
                  if(shelfNameChanged){
                    Navigator.of(context).pop();
                    // ref.read(loadingProvider.state).state = true;
                    // Future.delayed(const Duration(seconds: 2),() {
                    //   ref
                    //       .read(loadingProvider.state)
                    //       .state = false;
                    // });
                    // AsyncValue.loading = true;
                  }
                } on CustomException catch (e) {
                  ref.read(loadingProvider.state).state = false;
                  showToast(e.message.toString());
                }
              }
            },
            dialogHeight: 160,
            title: 'Change name',
            text: 'Change name from ${widget._shelf.shelfName} to ',
            textField1: CustomTextFormField(
              capitalization:
              TextCapitalization
                  .words,
              icon: Icons
                  .house_siding_rounded,
              hint: 'Enter Shelf Name',
              textEditingController:
              _newShelfName,
            ),
          );
        });
  }

  deleteShelf(){
    showDialog(
        context: context,
        builder: (_) {
          return MyDialog(
            buttonLabel: 'Delete',
            onPressed: () async {
              try{
                bool shelfDeleted = await _db.deleteShelf(widget._shelf);
                if(shelfDeleted){
                  Navigator.of(context).pop();
                }
              }on CustomException catch(e){
                showToast(e.message.toString());
              }
            },
            title: 'Delete ${widget._shelf.shelfName}',
            text: 'All books and data in this shelf will be permanently deleted.'
                '\nAre you sure you want to delete this shelf?',
            textStyle: const TextStyle(color: Colors.red),
            dialogHeight: 145,
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
