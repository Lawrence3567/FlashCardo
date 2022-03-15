import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flashcardo/app/home/models/flashcard.dart';
import 'package:flashcardo/app/home/models/study_set.dart';
import 'package:flashcardo/common_widget/show_alert_dialog.dart';
import 'package:flashcardo/common_widget/show_exception_alert_dialog.dart';
import 'package:flashcardo/services/database.dart';
import 'package:flashcardo/services/firebase_storage_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loader_overlay/loader_overlay.dart';

class EditSetPage extends StatefulWidget {
  const EditSetPage({Key key, @required this.database, this.studySet})
      : super(key: key);
  final Database database;
  final StudySet studySet;

  static Future<void> show(BuildContext context,
      {Database database, StudySet studySet}) async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => EditSetPage(
          database: database,
          studySet: studySet,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  _EditSetPageState createState() => _EditSetPageState();
}

class _EditSetPageState extends State<EditSetPage> {
  final _formKey = GlobalKey<FormState>();
  ScrollController _scrollController = ScrollController();

  List<String> _tempFlashcardIdList = [];
  List<Widget> _tempCardList = [];
  Map<String, Widget> _cardList = {};
  Map<String, TextEditingController> _termTECS = {};
  Map<String, TextEditingController> _defTECS = {};
  Map<String, String> _imageUrls = {};

  String _studySetTitle;
  bool _submitted = false;
  bool _firstTime = true;
  bool _isLoaderVisible = false;
  StreamBuilder _originalStudySetWidget;

  @override
  void initState() {
    super.initState();
    if (widget.studySet != null) {
      _studySetTitle = widget.studySet.name;
    }

    _originalStudySetWidget = StreamBuilder<List<Flashcard>>(
      stream: widget.database.flashcardsStream(widget.studySet.setId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final flashcardsList = snapshot.data;
          final children = flashcardsList
              .map((flashcard) => _card(
                    flashcard.flashcardId,
                    flashcard.term,
                    flashcard.definition,
                    FocusNode(),
                    flashcard.imgURL,
                  ))
              .toList();
          for (int i = 0; i < flashcardsList.length; ++i) {
            _tempFlashcardIdList.add(flashcardsList[i].flashcardId);
          }
          _tempCardList = List.from(children);
          for (int i = 0; i < _tempCardList.length; ++i) {
            _cardList[_tempFlashcardIdList[i]] = _tempCardList[i];
          }

          return Flexible(
            child: Scrollbar(
              child: ListView.builder(
                  controller: _scrollController,
                  primary: false,
                  itemCount: _cardList.length,
                  itemBuilder: (context, index) {
                    String key = _cardList.keys.elementAt(index);
                    return Column(
                      children: <Widget>[
                        Dismissible(
                          key: Key(key),
                          background: Container(color: Colors.red[400]),
                          direction: DismissDirection.startToEnd,
                          onDismissed: (direction) {
                            setState(() {
                              _deleteCard(key);
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              color: Colors.black12,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Column(children: [
                                  InkWell(
                                    onTap: () => selectImage(key),
                                    child: CircleAvatar(
                                      radius: 60,
                                      backgroundImage: _imageUrls[key] !=
                                              "empty"
                                          ? displayImage(_imageUrls[key])
                                          : AssetImage("images/cdimage.png"),
                                    ),
                                  ),
                                  _cardList[key],
                                ]),
                              ),
                            ),
                          ),
                        )
                      ],
                    );
                  },
                  addAutomaticKeepAlives: true),
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(child: Text("Some errors occured!"));
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _termTECS.forEach((key, value) {
      value.dispose();
    });
    _defTECS.forEach((key, value) {
      value.dispose();
    });
    super.dispose();
  }

  bool _validateAndSaveForm() {
    final form = _formKey.currentState;

    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void _clickSubmit() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmation'),
        content: Text('Save new changes of this study set?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _submit();
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _submit() async {
    setState(() {
      _submitted = true;
    });
    bool check1 = true;
    bool check2 = true;
    bool check3 = true;

    if (_termTECS.length < 4 || _defTECS.length < 4) {
      check1 = false;
    }
    if (_termTECS.length > 0) {
      for (String key in _termTECS.keys) {
        if (_termTECS[key].text.isEmpty) {
          check2 = false;
          break;
        }
      }
    }
    if (_defTECS.length > 0) {
      for (String key in _defTECS.keys) {
        if (_defTECS[key].text.isEmpty) {
          check3 = false;
          break;
        }
      }
    }

    if (_validateAndSaveForm() && check1 && check2 && check3) {
      try {
        final studySets = await widget.database.setsStream().first;
        final allSetNames = studySets.map((set) => set.name).toList();
        final flashcards =
            await widget.database.flashcardsStream(widget.studySet.setId).first;
        final allFlashcardsID =
            flashcards.map((flashcard) => flashcard.flashcardId).toList();
        print(allFlashcardsID);
        if (widget.studySet != null) {
          allSetNames.remove(widget.studySet.name);
        }
        if (allSetNames.contains(_studySetTitle)) {
          showAlertDialog(context,
              title: "Title already exists",
              content: "Please choose a different study set title!",
              defaultActionText: "OK");
        } else {
          final id = widget.studySet.setId;
          final newSet = StudySet(
              setId: id, name: _studySetTitle, cardAmount: _termTECS.length);
          await widget.database.createSet(newSet);
          context.loaderOverlay.show();
          setState(() {
            _isLoaderVisible = context.loaderOverlay.visible;
          });
          final List<String> tempList = [];
          for (String key in _termTECS.keys) {
            tempList.add(key);
            String downloadableURL = _imageUrls[key];
            if (_imageUrls[key] != "empty") {
              if (!_imageUrls[key].contains("https://firebasestorage"))
                downloadableURL = await uploadImage(_imageUrls[key]);
            } else {
              downloadableURL = "empty";
            }
            widget.database.createFlashcard(Flashcard(
                setId: id,
                flashcardId: key,
                term: _termTECS[key].text,
                definition: _defTECS[key].text,
                imgURL: downloadableURL));
          }

          for (int i = 0; i < allFlashcardsID.length; ++i) {
            if (!tempList.contains(allFlashcardsID[i])) {
              String key = allFlashcardsID[i];
              print("to be delete: $key");
              try {
                await widget.database.deleteFlashcard(id, key);
              } on FirebaseException catch (e) {
                print(e);
              }
            }
          }

          if (_isLoaderVisible) {
            context.loaderOverlay.hide();
          }
          setState(() {
            _isLoaderVisible = context.loaderOverlay.visible;
          });
          Navigator.of(context).pop();
        }
      } on FirebaseException catch (e) {
        showExceptionAlertDialog(
          context,
          title: "Operation failed",
          exception: e,
        );
      }
    } else if (!check1) {
      showAlertDialog(context,
          title: "Not enough flashcard",
          content: "Each study set requires a minimum of 4 flashcards in it!",
          defaultActionText: "OK");
    } else {
      showAlertDialog(context,
          title: "Information missing",
          content:
              "Some fields are not yet being filled! Please double check again!",
          defaultActionText: "OK");
    }
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData = MediaQuery.of(context);
    final _screenHeight = queryData.size.height;
    final _blockSize = _screenHeight / 100;

    return LoaderOverlay(
      overlayOpacity: 0.8,
      useDefaultLoading: false,
      overlayWidget: Center(
        child: SpinKitCubeGrid(
          color: Colors.lightGreenAccent[100],
          size: _blockSize * 6.057,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Edit Study Set"),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.check,
                color: Colors.black,
              ),
              onPressed: _clickSubmit,
            )
          ],
          elevation: 20,
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
              colors: [Colors.lightGreen[400], Colors.green[300]],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )),
          ),
        ),
        body: _buildContents(context),
        backgroundColor: Colors.grey[900],
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 65.0),
          child: FloatingActionButton(
            child: Icon(Icons.add),
            backgroundColor: Colors.white,
            onPressed: () {
              if (_cardList.length < 100) {
                setState(() {
                  _submitted = false;
                  String newFlashcardID = DateTime.now().toIso8601String();
                  final FocusNode newFocusNode = FocusNode();
                  _cardList[newFlashcardID] =
                      _card(newFlashcardID, "", "", newFocusNode, "empty");
                  FocusScope.of(context).requestFocus(newFocusNode);

                  _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent + 350,
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOut);

                  _firstTime = false;
                });
              } else {
                showAlertDialog(context,
                    title: "Over 100 flashcards",
                    content:
                        "Each study set is only allowed to contain up to 100 flashcards!",
                    defaultActionText: "OK");
              }
            },
            elevation: 50,
            tooltip: "Add a new flashcard",
          ),
        ),
      ),
    );
  }

  // Widget _testBuildContents(BuildContext context) {
  //   return StreamBuilder<List<Flashcard>>(
  //     stream: _getDatabase(this.widget).flashcardsStream(widget.studySet.setId),
  //     builder: (context, snapshot) {
  //       if (snapshot.hasData) {
  //         final flashcardsList = snapshot.data;
  //         final children = flashcardsList
  //             .map((flashcard) => _card(
  //                   flashcard.flashcardId,
  //                   flashcard.term,
  //                   flashcard.definition,
  //                   FocusNode(),
  //                   flashcard.imgURL,
  //                 ))
  //             .toList();
  //         if (_firstTime) {
  //           for (int i = 0; i < flashcardsList.length; ++i) {
  //             _tempFlashcardIdList.add(flashcardsList[i].flashcardId);
  //           }
  //           _tempCardList = List.from(children);
  //           for (int i = 0; i < _tempCardList.length; ++i) {
  //             _cardList[_tempFlashcardIdList[i]] = _tempCardList[i];
  //           }

  //           _firstTime = false;
  //         }

  //         return Column(
  //           children: [
  //             SingleChildScrollView(
  //               child: Padding(
  //                 padding: const EdgeInsets.all(16.0),
  //                 child: Card(
  //                   color: Colors.black12,
  //                   child: Padding(
  //                     padding: const EdgeInsets.all(16.0),
  //                     child: Form(
  //                         key: _formKey,
  //                         child: Column(
  //                           crossAxisAlignment: CrossAxisAlignment.stretch,
  //                           children: [
  //                             TextFormField(
  //                               style: TextStyle(
  //                                 color: Colors.white,
  //                                 fontWeight: FontWeight.w900,
  //                               ),
  //                               cursorColor: Colors.white,
  //                               decoration: InputDecoration(
  //                                 labelText: "Study Set Title",
  //                                 enabledBorder: UnderlineInputBorder(
  //                                   borderSide:
  //                                       BorderSide(color: Colors.blueGrey[200]),
  //                                 ),
  //                                 focusedBorder: OutlineInputBorder(
  //                                     borderSide: BorderSide(
  //                                         color: Colors.lightGreen[200])),
  //                               ),
  //                               initialValue: _studySetTitle,
  //                               validator: (value) {
  //                                 if (value == null || value.isEmpty) {
  //                                   return 'Title can\'t be empty';
  //                                 }
  //                                 return null;
  //                               },
  //                               onSaved: (value) => _studySetTitle = value,
  //                             )
  //                           ],
  //                         )),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //             Flexible(
  //               child: Scrollbar(
  //                 child: ListView.builder(
  //                     controller: _scrollController,
  //                     primary: false,
  //                     itemCount: _cardList.length,
  //                     itemBuilder: (context, index) {
  //                       String key = _cardList.keys.elementAt(index);
  //                       return Column(
  //                         children: <Widget>[
  //                           Dismissible(
  //                             key: Key(key),
  //                             background: Container(color: Colors.red[400]),
  //                             direction: DismissDirection.startToEnd,
  //                             onDismissed: (direction) {
  //                               setState(() {
  //                                 _deleteCard(key);
  //                               });
  //                             },
  //                             child: Padding(
  //                               padding: const EdgeInsets.all(8.0),
  //                               child: Card(
  //                                 color: Colors.black12,
  //                                 child: Padding(
  //                                   padding:
  //                                       const EdgeInsets.symmetric(vertical: 8),
  //                                   child: Column(children: [
  //                                     InkWell(
  //                                       onTap: () => selectImage(key),
  //                                       child: CircleAvatar(
  //                                         radius: 60,
  //                                         backgroundImage: _imageUrls[key] !=
  //                                                 "empty"
  //                                             //? NetworkImage(_imageUrls[key])
  //                                             ? displayImage(_imageUrls[key])
  //                                             : AssetImage(
  //                                                 "images/cdimage.png"),
  //                                       ),
  //                                     ),
  //                                     _cardList[key],
  //                                   ]),
  //                                 ),
  //                               ),
  //                             ),
  //                           )
  //                         ],
  //                       );
  //                     },
  //                     addAutomaticKeepAlives: true),
  //               ),
  //             ),
  //           ],
  //         );
  //       }
  //       if (snapshot.hasError) {
  //         return Center(child: Text("Some errors occured!"));
  //       }
  //       return Center(child: CircularProgressIndicator());
  //     },
  //   );
  // }

  Widget _buildContents(BuildContext context) {
    return Column(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: Colors.black12,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                            labelText: "Study Set Title",
                            enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.blueGrey[200]),
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.lightGreen[200])),
                          ),
                          initialValue: _studySetTitle,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Title can\'t be empty';
                            }
                            return null;
                          },
                          onSaved: (value) => _studySetTitle = value,
                        )
                      ],
                    )),
              ),
            ),
          ),
        ),
        if (_firstTime) _originalStudySetWidget,
        if (!_firstTime)
          Flexible(
            child: Scrollbar(
              child: ListView.builder(
                  controller: _scrollController,
                  primary: false,
                  itemCount: _cardList.length,
                  itemBuilder: (context, index) {
                    String key = _cardList.keys.elementAt(index);
                    return Column(
                      children: <Widget>[
                        Dismissible(
                          key: Key(key),
                          background: Container(color: Colors.red[400]),
                          direction: DismissDirection.startToEnd,
                          onDismissed: (direction) {
                            setState(() {
                              _deleteCard(key);
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              color: Colors.black12,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Column(children: [
                                  InkWell(
                                    onTap: () => selectImage(key),
                                    child: CircleAvatar(
                                      radius: 60,
                                      backgroundImage: _imageUrls[key] !=
                                              "empty"
                                          ? displayImage(_imageUrls[key])
                                          : AssetImage("images/cdimage.png"),
                                    ),
                                  ),
                                  _cardList[key],
                                ]),
                              ),
                            ),
                          ),
                        )
                      ],
                    );
                  },
                  addAutomaticKeepAlives: true),
            ),
          ),
      ],
    );
  }

  Widget _card(String flashcardID, String term, String definition,
      FocusNode focusNode, String imgURL) {
    String key = flashcardID;
    var termController = TextEditingController();
    var defController = TextEditingController();
    termController.text = term;
    defController.text = definition;
    _termTECS[key] = termController;
    _defTECS[key] = defController;
    _imageUrls[key] = imgURL;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        color: Colors.black12,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  labelText: "Term",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueGrey[200]),
                  ),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.lightGreen[200])),
                ),
                onChanged: (term) {
                  setState(() {});
                },
                controller: termController,
                focusNode: focusNode,
              ),
              TextField(
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  labelText: "Definition",
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueGrey[200]),
                  ),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.lightGreen[200])),
                ),
                onChanged: (definition) {
                  setState(() {});
                },
                controller: defController,
              )
            ],
          ),
        ),
      ),
    );
  }

  void _deleteCard(String key) {
    _firstTime = false;
    _cardList.remove(key);
    _termTECS.remove(key);
    _defTECS.remove(key);
    _imageUrls.remove(key);
  }

  ImageProvider<Object> displayImage(String imgURL) {
    if (imgURL.contains("https://firebasestorage")) {
      return NetworkImage(imgURL);
    } else {
      for (String key in _imageUrls.values) {
        print(key);
      }
      return FileImage(File(imgURL));
    }
  }

  Future<void> selectImage(String key) async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result == null) return;
    final path = result.files.single.path;

    setState(() {
      _imageUrls[key] = path;
    });
  }

  Future<String> uploadImage(String path) async {
    File file = File(path);
    String randStr = getRandomString(10);

    final fileName = file.path.split('/').last;
    final destination = "files/$randStr+${fileName}";
    print(destination);

    return FirebaseStorageApi.uploadFile(destination, file);
  }

  String getRandomString(int length) {
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }
}
