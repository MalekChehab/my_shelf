import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:my_library/models/book.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:my_library/services/custom_exception.dart';
import 'package:my_library/services/general_providers.dart';
import 'package:my_library/view/widgets/book_text_form_field.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart' as intl;
import 'add_book.dart';
import 'home_screen.dart';
import 'dart:io';

class BookDetails extends ConsumerStatefulWidget {
  final Book? book;

  const BookDetails({Key? key, required this.book}) : super(key: key);

  @override
  BookDetailsState createState() => BookDetailsState();
}

class BookDetailsState extends ConsumerState<BookDetails>
    with TickerProviderStateMixin {
  late double _height;
  late double _width;
  late TabController tabController;
  late var _db;
  late bool _isLoading = false;
  late File file = File('no file');

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    List tags = widget.book!.tags!.toList();
    _db = ref.watch(firebaseDatabaseProvider);
    return Scaffold(
      body: LoadingOverlay(
        isLoading: _isLoading,
        progressIndicator: CircularProgressIndicator(
          color: Theme.of(context).indicatorColor,
        ),
        child: DefaultTabController(
          length: 2,
          child: NestedScrollView(
            // scrollBehavior: const ScrollBehavior(androidOverscrollIndicator: AndroidOverscrollIndicator.stretch),
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: 270.0,
                  // floating: true,
                  pinned: true,
                  actions: [
                    PopupMenuButton<String>(
                      color: Theme.of(context).primaryColor,
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(children: [
                            Icon(
                              Icons.edit_rounded,
                              color: Theme.of(context).buttonColor,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Edit Book',
                              style: TextStyle(
                                  color: Theme.of(context).accentColor),
                            ),
                          ]),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(children: [
                            Icon(
                              Icons.delete_rounded,
                              color: Theme.of(context).buttonColor,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Delete Book',
                              style: TextStyle(
                                  color: Theme.of(context).accentColor),
                            ),
                          ]),
                        ),
                      ],
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        AddBook(book: widget.book)));
                            break;
                          case 'delete':
                            showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      title: Text(
                                        'Are you sure you want to delete this book?',
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle2,
                                      ),
                                      content: SizedBox(
                                          height: 30,
                                          // width: 30,
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10.0, right: 10.0),
                                                child: MyButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child:
                                                        const Text('Cancel')),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 10.0),
                                                child: MyButton(
                                                    onPressed: () async {
                                                      setState(() {
                                                        _isLoading = true;
                                                      });
                                                      try {
                                                        bool bookDeleted =
                                                            await _db
                                                                .deleteBook(
                                                                    widget
                                                                        .book);
                                                        if (bookDeleted) {
                                                          Navigator.pop(
                                                              context);
                                                          Future.delayed(
                                                              const Duration(
                                                                  seconds: 5),
                                                              () {
                                                            setState(() {
                                                              _isLoading =
                                                                  false;
                                                            });
                                                            Future.delayed(
                                                                const Duration(
                                                                    seconds: 2),
                                                                () {
                                                              Navigator.pushAndRemoveUntil(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (_) =>
                                                                              const HomeScreen()),
                                                                  (route) =>
                                                                      false);
                                                            });
                                                          });
                                                        }
                                                      } on CustomException catch (e) {
                                                        setState(() {
                                                          _isLoading = false;
                                                        });
                                                        Fluttertoast.showToast(
                                                          msg: e.message
                                                              .toString(),
                                                          toastLength:
                                                              Toast.LENGTH_LONG,
                                                        );
                                                      }
                                                    },
                                                    child:
                                                        const Text('Delete')),
                                              ),
                                            ],
                                          )),
                                    ));
                            break;
                        }
                      },
                    ),
                  ],
                  title: Marquee(
                    child: Text(widget.book!.title.toString()),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      children: [
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 40.0, top: 60),
                            child: Row(
                              children: [
                                Hero(
                                  tag: "SelectedBook-${widget.book!.id}",
                                  transitionOnUserGestures: true,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: widget.book!.coverUrl == ""
                                        ? const SizedBox(
                                            child: Placeholder(),
                                            height: 200,
                                            width: 110,
                                          )
                                        : CachedNetworkImage(
                                            imageUrl: widget.book!.coverUrl
                                                .toString(),
                                            height: 200,
                                            width: 110,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 200,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                widget.book!.author.join(', ')),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 15),
                                      Text(
                                        widget.book!.shelf!.shelfName,
                                        style: TextStyle(
                                          color: Theme.of(context).buttonColor,
                                          fontFamily: 'Nunito',
                                          fontSize: 17.0,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      Text(
                                        widget.book!.location.toString(),
                                        style: TextStyle(
                                          color: Theme.of(context).hintColor,
                                          fontFamily: 'Nunito',
                                          fontSize: 17.0,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      SizedBox(
                                        width: 200,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Wrap(
                                            spacing: 6.0,
                                            runSpacing: 6.0,
                                            children: List<Widget>.generate(
                                                tags.length, (int index) {
                                              return Chip(
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .buttonColor,
                                                label: Text(
                                                  tags[index],
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Theme.of(context)
                                                        .accentColor,
                                                  ),
                                                ),
                                              );
                                            }),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // tabs header
                SliverPersistentHeader(
                  // pinned: true,
                  floating: true,
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      labelColor: Theme.of(context).buttonColor,
                      unselectedLabelColor:
                          Theme.of(context).hintColor.withOpacity(.7),
                      tabs: const [
                        Tab(
                          icon: Icon(Icons.info_rounded),
                        ),
                        Tab(
                          icon: Icon(
                            Icons.lightbulb_outline_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: [
                // info tab
                SingleChildScrollView(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          'Title',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        subtitle: Text(widget.book!.title,
                            style: Theme.of(context).textTheme.bodyText2),
                      ),
                      ListTile(
                        title: Text(
                          'Author',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        subtitle: Text(widget.book!.author.join(', '),
                            style: Theme.of(context).textTheme.bodyText2),
                      ),
                      ListTile(
                        title: Text(
                          'Genre',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        subtitle: Text(widget.book!.genre.toString(),
                            style: Theme.of(context).textTheme.bodyText2),
                      ),
                      ListTile(
                        title: Text(
                          'Publisher',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        subtitle: Text(widget.book!.publisher.toString(),
                            style: Theme.of(context).textTheme.bodyText2),
                      ),
                      ListTile(
                        title: Text(
                          'Publish Date',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        subtitle: Text(widget.book!.publishDate.toString(),
                            style: Theme.of(context).textTheme.bodyText2),
                      ),
                      ListTile(
                        title: Text(
                          'Tags',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        subtitle: Text(widget.book!.tags!.join(', '),
                            style: Theme.of(context).textTheme.bodyText2),
                      ),
                      ListTile(
                        title: Text(
                          'ISBN',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        subtitle: Text(widget.book!.isbn.toString(),
                            style: Theme.of(context).textTheme.bodyText2),
                      ),
                      ListTile(
                        title: Text(
                          'Language',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        subtitle: Text(widget.book!.language.toString(),
                            style: Theme.of(context).textTheme.bodyText2),
                      ),
                      ListTile(
                        title: Text(
                          'Number of Pages',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        subtitle: Text(widget.book!.numberOfPages.toString(),
                            style: Theme.of(context).textTheme.bodyText2),
                      ),
                      ListTile(
                        title: Text(
                          'Edition',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        subtitle: Text(widget.book!.edition.toString(),
                            style: Theme.of(context).textTheme.bodyText2),
                      ),
                      ListTile(
                        title: Text(
                          'Edition Date',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        subtitle: Text(widget.book!.editionDate.toString(),
                            style: Theme.of(context).textTheme.bodyText2),
                      ),
                      ListTile(
                        title: Text(
                          'Shelf',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        subtitle: Text(widget.book!.shelf!.shelfName.toString(),
                            style: Theme.of(context).textTheme.bodyText2),
                      ),
                      ListTile(
                        title: Text(
                          'Location',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        subtitle: Text(widget.book!.location.toString(),
                            style: Theme.of(context).textTheme.bodyText2),
                      ),
                      ListTile(
                        title: Text(
                          'Description',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        subtitle: Text(widget.book!.description.toString(),
                            style: Theme.of(context).textTheme.bodyText2),
                      ),
                    ],
                  ),
                ),

                // notes tab
                SingleChildScrollView(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // date added
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 8,
                            top: 14,
                          ),
                          child: ListTile(
                            leading: Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Text(
                                'Date Added',
                                style: Theme.of(context).textTheme.headline6,
                              ),
                            ),
                            title: Text(
                              '${intl.DateFormat('dd MMM yyyy').format(widget.book!.dateAdded!)}'
                              ' at ${intl.DateFormat('jm').format(widget.book!.dateAdded!)}',
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                          ),
                        ),

                        // started reading
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 14),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    'Started Reading',
                                    style:
                                        Theme.of(context).textTheme.headline6,
                                  ),
                                ),
                                SizedBox(width: _width / 45),
                                MyButton(
                                  child: Icon(
                                    Icons.check,
                                    color: widget.book!.isReading == true
                                        ? Theme.of(context).indicatorColor
                                        : Theme.of(context)
                                            .hintColor
                                            .withOpacity(.4),
                                  ),
                                  color: Theme.of(context).primaryColor,
                                  shape: const CircleBorder(),
                                  elevation: 6,
                                  onPressed: () {
                                    if (widget.book!.isReading == true) {
                                      _checkBottomSheet(context, false);
                                    } else {
                                      setState(() {
                                        widget.book!.isReading = true;
                                        widget.book!.startReading =
                                            DateTime.now();
                                      });
                                    }
                                  },
                                ),
                                SizedBox(width: _width / 11),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: GestureDetector(
                                    child: widget.book!.startReading ==
                                            DateTime(1000, 1, 1)
                                        ? const Icon(
                                            Icons.calendar_today_rounded)
                                        : Column(
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  intl.DateFormat('dd-MM')
                                                      .format(widget
                                                          .book!.startReading!),
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Theme.of(context)
                                                        .iconTheme
                                                        .color,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                intl.DateFormat('yyyy').format(
                                                    widget.book!.startReading!),
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Theme.of(context)
                                                      .iconTheme
                                                      .color,
                                                ),
                                              ),
                                            ],
                                          ),
                                    onTap: () async {
                                      if (widget.book!.startReading ==
                                          DateTime(1000, 1, 1)) {
                                        _pickStartedDate();
                                      } else {
                                        _dateBottomSheet(context, false);
                                      }
                                    },
                                  ),
                                ),
                              ]),
                        ),

                        // finished reading
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 14),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    'Finished Reading',
                                    style:
                                        Theme.of(context).textTheme.headline6,
                                  ),
                                ),
                                MyButton(
                                  child: widget.book!.timesRead == 0 ||
                                          widget.book!.timesRead == 1
                                      ? Icon(
                                          Icons.check,
                                          color: widget.book!.isFinished == true
                                              ? Theme.of(context).indicatorColor
                                              : Theme.of(context)
                                                  .hintColor
                                                  .withOpacity(.4),
                                        )
                                      : Text(
                                          widget.book!.timesRead.toString(),
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .indicatorColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                  color: Theme.of(context).primaryColor,
                                  shape: const CircleBorder(),
                                  elevation: 6,
                                  onPressed: () {
                                    if (widget.book!.isFinished == true) {
                                      _checkBottomSheet(context, true);
                                    } else {
                                      setState(() {
                                        widget.book!.isFinished = true;
                                        widget.book!.timesRead = 1;
                                        widget.book!.isReading = true;
                                        widget.book!.pagesRead =
                                            widget.book!.numberOfPages;
                                        widget.book!.endReading =
                                            DateTime.now();
                                      });
                                    }
                                  },
                                ),
                                SizedBox(width: _width / 11),
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: GestureDetector(
                                    child: widget.book!.endReading ==
                                            DateTime(1000, 1, 1)
                                        ? const Icon(
                                            Icons.calendar_today_rounded)
                                        : Column(
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  intl.DateFormat('dd-MM')
                                                      .format(widget
                                                          .book!.endReading!),
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Theme.of(context)
                                                        .iconTheme
                                                        .color,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                intl.DateFormat('yyyy').format(
                                                    widget.book!.endReading!),
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Theme.of(context)
                                                      .iconTheme
                                                      .color,
                                                ),
                                              ),
                                            ],
                                          ),
                                    onTap: () async {
                                      if (widget.book!.endReading ==
                                          DateTime(1000, 1, 1)) {
                                        _pickFinishedDate();
                                      } else {
                                        _dateBottomSheet(context, true);
                                      }
                                    },
                                  ),
                                ),
                              ]),
                        ),

                        // pages read
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 14, 8, 0),
                          child: ListTile(
                            title: Text(
                              "Pages Read",
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.all(2),
                              child: Row(
                                children: <Widget>[
                                  IconButton(
                                    onPressed: () {
                                      if (widget.book!.pagesRead! > 0) {
                                        setState(() {
                                          widget.book!.pagesRead =
                                              widget.book!.pagesRead! - 1;
                                        });
                                      }
                                    },
                                    icon: Icon(
                                      Icons.remove_rounded,
                                      color: Theme.of(context)
                                          .accentColor
                                          .withOpacity(.8),
                                    ),
                                  ),
                                  Expanded(
                                    child: SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        activeTrackColor:
                                            Theme.of(context).primaryColor,
                                        inactiveTrackColor: Theme.of(context)
                                            .accentColor
                                            .withOpacity(.3),
                                        trackHeight: 6.0,
                                        thumbShape: CustomSliderThumbCircle(
                                            thumbRadius: 18,
                                            value: widget.book!.pagesRead!,
                                            min: 0,
                                            max: widget.book!.numberOfPages,
                                            circleColor:
                                                Theme.of(context).primaryColor),
                                        overlayColor: Theme.of(context)
                                            .hintColor
                                            .withOpacity(.2),
                                        valueIndicatorColor:
                                            Theme.of(context).backgroundColor,
                                        thumbColor:
                                            Theme.of(context).iconTheme.color,
                                      ),
                                      child: Slider(
                                          value: widget.book!.pagesRead!
                                              .toDouble(),
                                          max: widget.book!.numberOfPages
                                              .toDouble(),
                                          min: 0,
                                          onChanged: (value) {
                                            setState(() {
                                              widget.book!.pagesRead =
                                                  value.toInt();
                                            });
                                          }),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      if (widget.book!.pagesRead! <
                                          widget.book!.numberOfPages - 1) {
                                        setState(() {
                                          widget.book!.pagesRead =
                                              widget.book!.pagesRead! + 1;
                                        });
                                      }
                                    },
                                    icon: Icon(
                                      Icons.add_rounded,
                                      color: Theme.of(context)
                                          .accentColor
                                          .withOpacity(.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // rate
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0, bottom: 14),
                          child: ListTile(
                            title: Text('Rate',
                                style: Theme.of(context).textTheme.headline6),
                            subtitle: Center(
                              child: RatingBar.builder(
                                initialRating: widget.book!.rating!,
                                minRating: 0,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemPadding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                itemBuilder: (context, _) => Icon(
                                  Icons.star,
                                  color: Theme.of(context)
                                      .indicatorColor
                                      .withOpacity(.7),
                                ),
                                unratedColor: Theme.of(context)
                                    .accentColor
                                    .withOpacity(.3),
                                glow: false,
                                itemSize: 34,
                                onRatingUpdate: (rating) {
                                  setState(() {
                                    widget.book!.rating = rating;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),

                        // notes
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text('Notes',
                                style: Theme.of(context).textTheme.headline6),
                            subtitle: TextField(),
                          ),
                        ),

                        SizedBox(height: _height / 20),

                        // save button
                        SizedBox(
                          height: 50,
                          // width: double.infinity,
                          width: 130,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              foregroundColor: MaterialStateProperty.all<Color>(
                                  Theme.of(context).indicatorColor),
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Theme.of(context).buttonColor),
                            ),
                            child: const Text('Save'),
                            onPressed: () async {
                              try {
                                setState(() {
                                  _isLoading = true;
                                });
                                bool bookEdited = await _db.editBook(
                                    widget.book, widget.book!.shelf, file);
                                if (bookEdited) {
                                  Future.delayed(const Duration(seconds: 3),
                                      () {
                                    setState(() {
                                      _isLoading = false;
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
                            },
                          ),
                        ),
                      ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _pickStartedDate() async {
    DateTime? datePicked = await showDatePicker(
      context: context,
      initialDate: widget.book!.startReading == DateTime(1000, 1, 1) &&
              widget.book!.endReading == DateTime(1000, 1, 1)
          ? DateTime.now()
          : widget.book!.startReading == DateTime(1000, 1, 1)
              ? widget.book!.endReading!
              : widget.book!.startReading!,
      firstDate: DateTime(1950),
      lastDate: widget.book!.endReading == DateTime(1000, 1, 1)
          ? DateTime.now()
          : widget.book!.endReading!,
    );
    if (datePicked != null && datePicked != widget.book!.startReading) {
      setState(() {
        widget.book!.startReading = datePicked;
        widget.book!.isReading = true;
      });
    }
  }

  void _pickFinishedDate() async {
    DateTime? datePicked = await showDatePicker(
      context: context,
      initialDate: widget.book!.endReading == DateTime(1000, 1, 1)
          ? DateTime.now()
          : widget.book!.endReading!,
      firstDate: widget.book!.startReading == DateTime(1000, 1, 1)
          ? DateTime(1950)
          : widget.book!.startReading!,
      lastDate: DateTime.now(),
    );
    if (datePicked != null && datePicked != widget.book!.endReading) {
      setState(() {
        widget.book!.endReading = datePicked;
        widget.book!.isFinished = true;
        widget.book!.pagesRead = widget.book!.numberOfPages;
      });
    }
  }

  void _checkBottomSheet(BuildContext context, bool finishedReading) {
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
            child: SafeArea(
              child: Wrap(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 19.0, left: 8, bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.remove_circle_outline_rounded),
                      title: const Text('Remove'),
                      onTap: () {
                        setState(() {
                          if (!finishedReading) {
                            widget.book!.isReading = false;
                            widget.book!.pagesRead = 0;
                            widget.book!.startReading = DateTime(1000, 1, 1);
                          }
                          widget.book!.isFinished = false;
                          widget.book!.endReading = DateTime(1000, 1, 1);
                          widget.book!.timesRead = 0;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  SizedBox(height: finishedReading ? _height / 10 : 0),
                  finishedReading
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: const Icon(Icons.plus_one_rounded),
                            title: const Text('Reread'),
                            onTap: () {
                              setState(() {
                                widget.book!.timesRead =
                                    widget.book!.timesRead! + 1;
                              });
                              Navigator.pop(context);
                            },
                          ),
                        )
                      : const SizedBox(),
                  finishedReading && widget.book!.timesRead! > 1
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListTile(
                            leading: const Icon(Icons.looks_one_rounded),
                            title: const Text('Read just once'),
                            onTap: () {
                              setState(() {
                                widget.book!.timesRead = 1;
                              });
                              Navigator.pop(context);
                            },
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          );
        });
  }

  void _dateBottomSheet(BuildContext context, bool finishedReading) {
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
            child: SafeArea(
              child: Wrap(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListTile(
                      leading: const Icon(Icons.edit_rounded),
                      title: const Text('Change Date'),
                      onTap: () {
                        Navigator.pop(context);
                        if (finishedReading) {
                          _pickFinishedDate();
                        } else {
                          _pickStartedDate();
                        }
                      },
                    ),
                  ),
                  SizedBox(height: _height / 10),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 19.0, left: 8, bottom: 8),
                    child: ListTile(
                      leading: const Icon(Icons.remove_circle_outline_rounded),
                      title: const Text('Remove Date'),
                      onTap: () {
                        setState(() {
                          if (!finishedReading) {
                            widget.book!.startReading = DateTime(1000, 1, 1);
                          } else {
                            widget.book!.endReading = DateTime(1000, 1, 1);
                          }
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class CustomSliderThumbCircle extends SliderComponentShape {
  final double thumbRadius;
  final int min;
  final int max;
  final Color? circleColor;
  final int? value;

  const CustomSliderThumbCircle({
    required this.thumbRadius,
    this.min = 0,
    this.max = 10,
    this.circleColor,
    this.value,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    Animation<double>? activationAnimation,
    Animation<double>? enableAnimation,
    bool? isDiscrete,
    TextPainter? labelPainter,
    RenderBox? parentBox,
    SliderThemeData? sliderTheme,
    TextDirection? textDirection,
    double? value,
    double? textScaleFactor,
    Size? sizeWithOverflow,
  }) {
    isDiscrete = true;
    final Canvas canvas = context.canvas;

    final paint = Paint()
      ..color = circleColor! //Thumb Background Color
      ..style = PaintingStyle.fill;

    TextSpan span = TextSpan(
      style: TextStyle(
        fontSize: thumbRadius * .8,
        fontWeight: FontWeight.w700,
        color: sliderTheme!.thumbColor, //Text Color of Value on Thumb
      ),
      // text: getValue(value!),
      text: this.value.toString(),
    );

    TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    tp.layout();
    Offset textCenter =
        Offset(center.dx - (tp.width / 2), center.dy - (tp.height / 2));

    canvas.drawCircle(center, thumbRadius * .9, paint);
    tp.paint(canvas, textCenter);
  }

  String getValue(double value) {
    return (min + (max - min) * value).round().toString();
  }
}
