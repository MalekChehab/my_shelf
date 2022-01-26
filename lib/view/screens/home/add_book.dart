import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:my_library/models/book.dart';
import 'package:my_library/models/shelf.dart';
import 'package:my_library/services/custom_exception.dart';
import 'package:my_library/services/general_providers.dart';
import 'package:my_library/view/screens/home/book_details.dart';
import 'package:my_library/view/screens/home/home_screen.dart';
import 'package:my_library/view/screens/home/select_shelves_screen.dart';
import 'package:my_library/view/widgets/book_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:my_library/controllers/responsive_ui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class AddBook extends ConsumerStatefulWidget {
  late Shelf? shelf;
  final Book? book;
  AddBook({Key? key, this.shelf, this.book}) : super(key: key);

  @override
  AddBookState createState() => AddBookState();
}

class AddBookState extends ConsumerState<AddBook> {
  late double _height;
  late double _width;
  late double _pixelRatio;
  late bool _large;
  late bool _medium;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _title;
  late TextEditingController _author;
  late TextEditingController _genre;
  late TextEditingController _tags;
  late TextEditingController _location;
  late TextEditingController _translator;
  late TextEditingController _publisher;
  late TextEditingController _publishDate;
  late TextEditingController _isbn;
  late TextEditingController _numberOfPages;
  late TextEditingController _language;
  late TextEditingController _description;
  late TextEditingController _edition;
  late TextEditingController _editionDate;
  bool _imageTaken = false;
  late File _imageFile = File('no image');
  final picker = ImagePicker();
  late bool _isLoading = false;
  late var _db;
  late Book newBook;

  @override
  void initState() {
    _title = TextEditingController(
        text: widget.book == null ? null : widget.book!.title);
    _author = TextEditingController(
        text: widget.book == null ? null : widget.book!.author.join(', '));
    _genre = TextEditingController(
        text: widget.book == null ? null : widget.book!.genre);
    _location = TextEditingController(
        text: widget.book == null ? null : widget.book!.location);
    _tags = TextEditingController(
        text: widget.book == null ? null : widget.book!.tags!.join(', '));
    _translator = TextEditingController(
        text: widget.book == null ? null : widget.book!.translator);
    _publisher = TextEditingController(
        text: widget.book == null ? null : widget.book!.publisher);
    _publishDate = TextEditingController(
        text: widget.book == null ? null : widget.book!.publishDate);
    _isbn = TextEditingController(
        text: widget.book == null ? null : widget.book!.isbn);
    _numberOfPages = TextEditingController(
        text: widget.book == null ? null : widget.book!.numberOfPages.toString());
    _language = TextEditingController(
        text: widget.book == null ? null : widget.book!.language);
    _description = TextEditingController(
        text: widget.book == null ? null : widget.book!.description);
    _edition = TextEditingController(
        text: widget.book == null ? null : widget.book!.edition);
    _editionDate = TextEditingController(
        text: widget.book == null ? null : widget.book!.editionDate);

    if (widget.shelf == null && widget.book != null) {
      widget.shelf = widget.book!.shelf;
    }
    // if(widget.book != null && widget.book!.coverUrl != ""){
    //   _imageTaken = true;
    // }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    _pixelRatio = MediaQuery.of(context).devicePixelRatio;
    _large = ResponsiveWidget.isScreenLarge(_width, _pixelRatio);
    _medium = ResponsiveWidget.isScreenMedium(_width, _pixelRatio);
    _db = ref.watch(firebaseDatabaseProvider);
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: widget.book == null
              ? const Text('Add Book')
              : const Text('Edit Book'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back,),
            onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (_) => widget.book == null ?
                    const HomeScreen()
                        : BookDetails(book: widget.book),
                ),
            ),
          ),
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
            numberOfPagesTextFormField(),
            SizedBox(height: _height / 60.0),
            locationTextFormField(),
            SizedBox(height: _height / 60.0),
            tagsTextFormField(),
            SizedBox(height: _height / 60.0),
            translatorTextFormField(),
            SizedBox(height: _height / 60.0),
            publisherTextFormField(),
            SizedBox(height: _height / 60.0),
            publishDateTextFormField(),
            SizedBox(height: _height / 60.0),
            isbnTextFormField(),
            SizedBox(height: _height / 60.0),
            languageTextFormField(),
            SizedBox(height: _height / 60.0),
            descriptionTextFormField(),
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
                        editionDateTextFormField(),
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
    return MyButton(
      onPressed: () {
        widget.book == null
            ? Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const SelectShelf()))
            : null;
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
            Icon(Icons.house_siding_rounded, color: Theme.of(context).buttonColor),
            const SizedBox(width: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                // widget.book == null ?
                widget.shelf != null
                    ? widget.shelf!.getShelfName()
                    : 'Select Shelf'
                // : widget.book!.shelf!.getShelfName()
                ,
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
      capitalization: TextCapitalization.words,
    );
  }

  Widget authorTextFormField() {
    return CustomTextFormField(
      hint: 'Author (Separate by comma)',
      textEditingController: _author,
      icon: Icons.person_outline_rounded,
      capitalization: TextCapitalization.words,
    );
  }

  Widget genreTextFormField() {
    return CustomTextFormField(
      hint: 'Genre',
      textEditingController: _genre,
      icon: Icons.category_outlined,
      capitalization: TextCapitalization.words,
    );
  }

  Widget numberOfPagesTextFormField() {
    return CustomTextFormField(
      hint: 'Number of Pages',
      textEditingController: _numberOfPages,
      keyboardType: TextInputType.number,
      icon: Icons.collections_bookmark,
    );
  }

  Widget locationTextFormField() {
    return CustomTextFormField(
      hint: 'Location (optional)',
      textEditingController: _location,
      icon: Icons.location_on_outlined,
      capitalization: TextCapitalization.words,
    );
  }

  Widget tagsTextFormField() {
    return CustomTextFormField(
      hint: 'Tags (Separate by comma)',
      textEditingController: _tags,
      icon: Icons.tag_rounded,
      capitalization: TextCapitalization.words,
    );
  }

  Widget translatorTextFormField() {
    return CustomTextFormField(
      hint: 'Translator (optional)',
      textEditingController: _translator,
      icon: Icons.translate_rounded,
      capitalization: TextCapitalization.words,
    );
  }

  Widget publisherTextFormField() {
    return CustomTextFormField(
      hint: 'Publisher (optional)',
      textEditingController: _publisher,
      icon: Icons.book_online_rounded,
      capitalization: TextCapitalization.words,
    );
  }

  Widget publishDateTextFormField() {
    return CustomTextFormField(
      hint: 'Publish Date (optional)',
      textEditingController: _publishDate,
      icon: Icons.calendar_today_rounded,
      keyboardType: TextInputType.datetime,
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

  Widget languageTextFormField() {
    return CustomTextFormField(
      hint: 'Language (optional)',
      textEditingController: _language,
      icon: Icons.language_rounded,
      capitalization: TextCapitalization.words,
    );
  }

  Widget descriptionTextFormField() {
    return CustomTextFormField(
      hint: 'Description (optional)',
      textEditingController: _description,
      icon: Icons.description,
      capitalization: TextCapitalization.sentences,
      keyboardType: TextInputType.multiline,
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

  Widget editionDateTextFormField() {
    return CustomTextFormField(
      hint: 'Ed. Date',
      textEditingController: _editionDate,
      icon: Icons.calendar_today_rounded,
      keyboardType: TextInputType.datetime,
    );
  }

  Widget coverFormField(BuildContext context) {
    return _imageTaken == true && _imageFile.path != 'no image'
        ? GestureDetector(
            child: Container(
              height:
                  _large ? _height / 5 : (_medium ? _height / 10 : _height / 7),
              width: _large
                  ? _width / 2
                  : (_medium ? _width / 3.75 : _width / 3.5),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                image: DecorationImage(
                  image: FileImage(_imageFile),
                ),
              ),
            ),
            onTap: () => _showPicker(context),
          )
        : widget.book != null && widget.book!.coverUrl.toString() != ""
            ? GestureDetector(
                child: Container(
                  height: _large
                      ? _height / 5
                      : (_medium ? _height / 10 : _height / 7),
                  width: _large
                      ? _width / 2
                      : (_medium ? _width / 3.75 : _width / 3.5),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                    image: DecorationImage(
                        image: NetworkImage(widget.book!.coverUrl.toString())),
                  ),
                ),
                onTap: () => _showPicker(context),
              )
            : MyButton(
                child: Container(
                  height: _large
                      ? _height / 5
                      : (_medium ? _height / 10 : _height / 7),
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

  Widget confirmButton(BuildContext context) {
    return MyButton(
        child: Container(
          alignment: Alignment.center,
          height: _height / 13,
          width: _large ? _width / 2 : (_medium ? _width / 3.75 : _width / 3.5),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
          ),
          padding: const EdgeInsets.all(12.0),
          child: Text(
            widget.book == null ? 'Add Book' : 'Save',
            style: TextStyle(
                fontSize: _large ? 18 : (_medium ? 12 : 10),
                color: Theme.of(context).iconTheme.color),
          ),
        ),
        color: Theme.of(context).primaryColor,
        elevation: _large ? 12 : (_medium ? 10 : 8),
        onPressed: () async {
          widget.shelf == null
              ? Fluttertoast.showToast(
                  msg: 'Please select a shelf',
                  toastLength: Toast.LENGTH_LONG,
                )
              : uploadData();
        });
  }

  Future<void> uploadData() async {
    setState(() {
      _isLoading = true;
    });
    newBook = Book(
      shelf: widget.shelf,
      title: _title.text,
      author: _author.text == "" ? [""] : (_author.text).split(', '),
      genre: _genre.text == "" ? "" : _genre.text,
      numberOfPages: _numberOfPages.text == "" ? 0 : int.parse(_numberOfPages.text),
      location: _location.text == "" ? "" : _location.text,
      tags: _tags.text == "" ? [""] : (_tags.text).split(', '),
      translator: _translator.text == "" ? "" : _translator.text,
      publisher: _publisher.text == "" ? "" : _publisher.text,
      publishDate: _publishDate.text == "" ? "" : _publishDate.text,
      isbn: _isbn.text == "" ? "" : _isbn.text,
      language: _language.text == "" ? "" : _language.text,
      description: _description.text == "" ? "" : _description.text,
      edition: _edition.text == "" ? "" : _edition.text,
      editionDate: _editionDate.text == "" ? "" : _editionDate.text,
      // coverUrl: "",
    );
    if (_formKey.currentState!.validate()) {
      if (widget.book == null) {
        try {
          bool bookAdded = await _db.addBook(newBook, widget.shelf, _imageFile);
          if (bookAdded) {
            ScaffoldMessenger.of(context).showMaterialBanner(
              MaterialBanner(
                backgroundColor: Theme.of(context).buttonColor,
                content: Text(
                    '${_title.text} has been added to ${widget.shelf!.shelfName}'),
                actions: [
                  TextButton(
                    child: const Text('Dismiss'),
                    onPressed: () => ScaffoldMessenger.of(context)
                        .hideCurrentMaterialBanner(),
                  ),
                ],
              ),
            );
            Future.delayed(const Duration(seconds: 5), () {
              setState(() {
                _isLoading = false;
              });
              Future.delayed(const Duration(seconds: 3), () {
                ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false);
              });
            });
          }
        } on CustomException catch (e) {
          setState(() {
            _isLoading = false;
          });
          Fluttertoast.showToast(
            msg: e.message.toString(),
            toastLength: Toast.LENGTH_LONG,
          );
        }
      } else {
        try {
          newBook.id = widget.book!.id;
          bool bookEdited =
              await _db.editBook(newBook, widget.shelf, _imageFile);
          if (bookEdited) {
            ScaffoldMessenger.of(context).showMaterialBanner(
              MaterialBanner(
                backgroundColor: Theme.of(context).buttonColor,
                content: Text('${_title.text} has been edited'),
                actions: [
                  TextButton(
                    child: const Text('Dismiss'),
                    onPressed: () => ScaffoldMessenger.of(context)
                        .hideCurrentMaterialBanner(),
                  ),
                ],
              ),
            );
            Future.delayed(const Duration(seconds: 3), () {
              setState(() {
                _isLoading = false;
              });
              Future.delayed(const Duration(seconds: 3), () {
                ScaffoldMessenger.of(context).removeCurrentMaterialBanner();
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) =>
                        // BookDetails(book: newBook)
                      const HomeScreen(),
                    ),
                        // (route) => false
                );
              });
            });
          }
        } on CustomException catch (e) {
          setState(() {
            _isLoading = false;
          });
          Fluttertoast.showToast(
            msg: e.message.toString(),
            toastLength: Toast.LENGTH_LONG,
          );
        }
      }
    }
  }

  _imgFromCamera() async {
    final pickedFile = await picker.pickImage(
      maxHeight: 800,
      maxWidth: 600,
      source: ImageSource.camera,
    ).then((value) =>
      _cropImage(value!.path).whenComplete(() {
        setState(() {
          _imageTaken = true;
        });
      })
      // setState((){
      //   _imageTaken = true;
      // });
    );
    // _cropImage(pickedFile!.path);
    // setState(() {
    //   // _imageFile = File(pickedFile!.path);
    //   _imageTaken = true;
    // });
  }

  _imgFromGallery() async {
    final pickedFile = await picker.pickImage(
      maxHeight: 800,
      maxWidth: 600,
      source: ImageSource.gallery,
    ).then((value) =>
        _cropImage(value!.path).whenComplete(() {
          setState(() {
            _imageTaken = true;
          });
        })
    );
    // _cropImage(pickedFile!.path);
    // setState(() {
    //   // _imageFile = File(pickedFile!.path);
    //   _imageTaken = true;
    // });
  }

  Future<void> _cropImage(String path) async {
    File? croppedFile = await ImageCropper.cropImage(
        sourcePath: path,
        aspectRatioPresets: Platform.isAndroid
            ? [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ]
            : [
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio5x3,
          CropAspectRatioPreset.ratio5x4,
          CropAspectRatioPreset.ratio7x5,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Theme.of(context).accentColor,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: const IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {
      setState(() {
        _imageFile = croppedFile;
      });
    }
  }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Theme.of(context).backgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        builder: (BuildContext bc) {
          return SizedBox(
            // height: _height / 4,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top:18.0),
                child: Wrap(
                  children: [
                    widget.book != null && widget.book!.coverUrl.toString() != ''
                        ? Padding(
                      padding: const EdgeInsets.only( left: 8, bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.clear_rounded),
                        title: const Text('Remove Image'),
                        onTap: () {
                          setState(() {
                            _imageFile = File('delete image');
                            _imageTaken = false;
                            widget.book!.coverUrl = "";
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ):const SizedBox(),
                    Padding(
                      padding:
                          const EdgeInsets.only( left: 8, bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.photo_library_rounded),
                        title: const Text('Gallery'),
                        onTap: () {
                          _imgFromGallery();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    SizedBox(height: _height / 10),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: const Icon(Icons.photo_camera_rounded),
                        title: const Text('Camera'),
                        onTap: () {
                          _imgFromCamera();
                          Navigator.pop(context);
                        },
                      ),
                    ),

                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  void dispose(){
    super.dispose();
  }
}
