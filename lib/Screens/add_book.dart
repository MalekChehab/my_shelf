import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:my_library/Models/book.dart';
import 'package:my_library/Models/shelf.dart';
import 'package:my_library/Screens/home_screen.dart';
import 'package:my_library/Screens/select_shelves_screen.dart';
import 'package:my_library/Widgets/book_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:my_library/Widgets/responsive_ui.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:image_picker/image_picker.dart';
// import 'package:fluttertoast/fluttertoast.dart';

class AddBook extends StatefulWidget {
  late Shelf? shelf;
  AddBook({Key? key, this.shelf}) : super(key: key);

  @override
  State<AddBook> createState() => _AddBookState();
}

class _AddBookState extends State<AddBook> {
  late double _height;
  late double _width;
  late double _pixelRatio;
  late bool _large;
  late bool _medium;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _title = TextEditingController();
  final TextEditingController _author = TextEditingController();
  final TextEditingController _publisher = TextEditingController();
  final TextEditingController _translator = TextEditingController();
  final TextEditingController _genre = TextEditingController();
  final TextEditingController _tags = TextEditingController();
  final TextEditingController _isbn = TextEditingController();
  final TextEditingController _numberOfPages = TextEditingController();
  final TextEditingController _description = TextEditingController();
  final TextEditingController _location = TextEditingController();
  final TextEditingController _edition = TextEditingController();
  final TextEditingController _publishDate = TextEditingController();
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final db = FirebaseFirestore.instance;
  bool _imageTaken = false;
  late File _imageFile;
  final picker = ImagePicker();
  late List<Shelf> shelves = [];
  String selectedValue = 'My Shelf';
  late bool _isLoading = false;

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
          title: const Text('Add Book'),
        ),
        body: SizedBox(
          height: _height,
          width: _width,
          child: LoadingOverlay(
            isLoading: _isLoading,
            progressIndicator: CircularProgressIndicator(
                color: Theme.of(context).indicatorColor,
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  form(context),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: confirmButton(context),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget form(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        left: _width / 12,
        right: _width / 12,
        top: _height / 30,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            selectShelf(),
            SizedBox(height: _height / 60.0),
            titleTextFormField(),
            SizedBox(height: _height / 60.0),
            authorTextFormField(),
            SizedBox(height: _height / 60.0),
            genreTextFormField(),
            SizedBox(height: _height / 60.0),
            locationTextFormField(),
            SizedBox(height: _height / 60.0),
            tagsTextFormField(),
            SizedBox(height: _height / 60.0),
            isbnTextFormField(),
            SizedBox(height: _height / 60.0),
            publisherTextFormField(),
            SizedBox(height: _height / 60.0),
            publishDateTextFormField(),
            SizedBox(height: _height / 60.0),
            translatorTextFormField(),
            SizedBox(height: _height / 60.0),
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 3.0),
                    child: coverFormField(context),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 3.0),
                    child: Column(
                      children: [
                        editionTextFormField(),
                        SizedBox(height: _height / 60.0),
                        numberOfPagesTextFormField(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget selectShelf() {
    return Button(
      onPressed: (){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SelectShelf()));
      },
      child: Container(
        alignment: Alignment.center,
        height: _height / 11.5,
        width: _large ? _width / 1.2 : (_medium ? _width / 3.75 : _width / 3.5),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(
                Icons.house_siding,
                color: Theme.of(context).buttonColor),
            const SizedBox(width: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.shelf != null ? widget.shelf!.getShelfName()
                : 'Select Shelf',
                style: Theme.of(context).textTheme.subtitle2,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Theme.of(context).textTheme.caption!.color,
            ),
          ],
        ),
      ),
      color: Theme.of(context).backgroundColor,
      elevation: _large ? 12 : (_medium ? 10 : 8),
    );
  }

  Widget titleTextFormField() {
    return CustomTextFormField(
      hint: 'Title',
      textEditingController: _title,
      icon: Icons.menu_book_rounded,
      validator: (dynamic value) => value.isEmpty ? 'Enter a title' : null,
    );
  }

  Widget authorTextFormField() {
    return CustomTextFormField(
      hint: 'Author',
      textEditingController: _author,
      icon: Icons.person_outline_rounded,
    );
  }

  Widget publisherTextFormField() {
    return CustomTextFormField(
      hint: 'Publisher (optional)',
      textEditingController: _publisher,
      icon: Icons.book_online_rounded,
    );
  }

  Widget translatorTextFormField() {
    return CustomTextFormField(
      hint: 'Translator (optional)',
      textEditingController: _translator,
      icon: Icons.translate_rounded,
    );
  }

  Widget tagsTextFormField() {
    return CustomTextFormField(
      hint: 'Tags (optional)',
      textEditingController: _tags,
      icon: Icons.tag_rounded,
    );
  }

  Widget genreTextFormField() {
    return CustomTextFormField(
      hint: 'Genre',
      textEditingController: _genre,
      icon: Icons.category_outlined,
    );
  }

  Widget isbnTextFormField() {
    return CustomTextFormField(
      hint: 'ISBN (optional)',
      textEditingController: _isbn,
      icon: Icons.book_rounded,
      keyboardType: TextInputType.number,
    );
  }

  Widget editionTextFormField() {
    return CustomTextFormField(
      hint: 'Edition',
      textEditingController: _edition,
      icon: Icons.book_rounded,
      keyboardType: TextInputType.number,
    );
  }

  Widget publishDateTextFormField() {
    return CustomTextFormField(
      hint: 'Publish Date (optional)',
      textEditingController: _publishDate,
      icon: Icons.book_rounded,
      keyboardType: TextInputType.datetime,
    );
  }

  Widget coverFormField(BuildContext context) {
    return _imageTaken
        ? Container(
            child: Image.file(_imageFile),
            height:
                _large ? _height / 5 : (_medium ? _height / 10 : _height / 7),
            width:
                _large ? _width / 2 : (_medium ? _width / 3.75 : _width / 3.5),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
          )
        : Button(
            child: Container(
              // alignment: Alignment.center,
              height:
                  _large ? _height / 5 : (_medium ? _height / 10 : _height / 7),
              width: _large
                  ? _width / 2
                  : (_medium ? _width / 3.75 : _width / 3.5),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
              child: Icon(
                Icons.camera_alt_outlined,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
            color: Theme.of(context).backgroundColor,
            elevation: _large ? 20 : (_medium ? 10 : 8),
            onPressed: () => _showPicker(context),
          );
  }

  Widget locationTextFormField() {
    return CustomTextFormField(
      hint: 'Location (optional)',
      textEditingController: _location,
      icon: Icons.location_on_outlined,
    );
  }

  Widget numberOfPagesTextFormField() {
    return CustomTextFormField(
      hint: 'Pages',
      textEditingController: _numberOfPages,
      keyboardType: TextInputType.number,
      icon: Icons.collections_bookmark,
    );
  }

  Widget confirmButton(BuildContext context) {
    return Button(
      child: Container(
        alignment: Alignment.center,
        height: _height / 13,
        width: _large ? _width / 2 : (_medium ? _width / 3.75 : _width / 3.5),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
        padding: const EdgeInsets.all(12.0),
        child: Text(
          'Add Book',
          style: TextStyle(
              fontSize: _large ? 18 : (_medium ? 12 : 10),
              color: Theme.of(context).iconTheme.color),
        ),
      ),
      color: Theme.of(context).primaryColor,
      elevation: _large ? 12 : (_medium ? 10 : 8),
      onPressed: () async {
        widget.shelf == null ? Fluttertoast.showToast(
          msg: 'Please select a shelf',
          toastLength: Toast.LENGTH_LONG,
        ) : uploadData();
      }
    );
  }
  // late int totalBooks = 0;
  void uploadData(){
      if (_formKey.currentState!.validate()) {
        setState(() {
          _isLoading = true;
        });
        String fileName = '${_title.text}.jpg';
        db.collection('users').doc(uid).collection(widget.shelf!.getShelfName())
            .add({
          "title": _title.text,
          "author": _author.text == "" ? ["Unknown"]:(_author.text).split(','),
          "publisher": _publisher.text == "" ? "Unknown":_publisher.text,
          "translator": _translator.text == "" ? "Unknown":_translator.text,
          "genre": _genre.text == "" ? "Unknown":_genre.text,
          "tags": _tags.text == "" ? ["Unknown"]:(_tags.text).split(','),
          "ISBN": _isbn.text == "" ? "Unknown":_isbn.text,
          "number_of_pages": _numberOfPages.text == "" ? "Unknown":_numberOfPages.text,
          "date_added": DateTime.now().toString(),
          "shelf":widget.shelf!.getShelfName(),
          "description": "",
          "location":_location.text == "" ? "Unknown": _location.text,
          "is_finished": "",
          "pages_read": "",
          "is_reading": "",
          "start_reading": "",
          "end_reading": "",
          "edition": _edition.text == "" ? "Unknown":_edition.text,
          "edition_date": _publishDate.text == "" ? "Unknown":_publishDate.text,
          "cover": "",
        }).then((book) {
          uploadImageToFirebase(fileName, book.id);
          db.collection('users').doc(uid).set({
            "shelves": FieldValue.arrayUnion([widget.shelf!.getShelfName()]),
            "authors": FieldValue.arrayUnion(_author.text.split(',')),
            "tags": FieldValue.arrayUnion(_tags.text.split(',')),
            "genre": FieldValue.arrayUnion([_genre.text]),
            "publisher": FieldValue.arrayUnion([_publisher.text]),
            "total_books": FieldValue.increment(1),
          }, SetOptions(merge: true));
          // Book newBook = Book(
          //   id: book.id,
          //   shelf: widget.shelf,
          //   title: _title.text,
          //   author: [_author.text],
          //   genre: _genre.text,
          //   dateAdded: DateTime.now().toString(),
          // );
          Future.delayed(const Duration(seconds: 5), (){
            setState(() {
              _isLoading = false;
            });
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false
            );
          });
        });
      }
    }

  Future uploadImageToFirebase(String fileName, String bookId) async {
    try {
      TaskSnapshot snapshot = await FirebaseStorage.instance
          .ref('book_covers/$fileName')
          .putFile(_imageFile);
      if (snapshot.state == TaskState.success) {
        final String downloadUrl = await snapshot.ref.getDownloadURL();
        await db.collection('users').doc(uid)
            .collection(widget.shelf!.getShelfName()).doc(bookId).set({
          "cover": downloadUrl,
        }, SetOptions(merge: true)).then((value) => print('success'));
      } else {
        print('Error from image repo ${snapshot.state.toString()}');
        throw ('This file is not an image');
      }
    } on firebase_core.FirebaseException catch (e) {
      print(e);
    }
  }

  _imgFromCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      _imageFile = File(pickedFile!.path);
      _imageTaken = true;
    });
  }

  _imgFromGallery() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _imageFile = File(pickedFile!.path);
      _imageTaken = true;
    });
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded),
                  title: const Text('Gallery'),
                  onTap: () {
                    _imgFromGallery();
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera_rounded),
                  title: const Text('Camera'),
                  onTap: () {
                    _imgFromCamera();
                    Navigator.pop(context);
                  },
                )
              ],
            ),
          );
        });
  }
}
