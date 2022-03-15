import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flashcardo/app/home/models/flashcard.dart';
import 'package:flashcardo/app/home/models/study_set.dart';
import 'package:flashcardo/app/home/study_set/add_term_def_card.dart.dart';
import 'package:flashcardo/common_widget/show_alert_dialog.dart';
import 'package:flashcardo/common_widget/show_exception_alert_dialog.dart';
import 'package:flashcardo/services/database.dart';
import 'package:flashcardo/services/firebase_storage_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';

class AddSetPage extends StatefulWidget {
  const AddSetPage({Key key, @required this.database}) : super(key: key);
  final Database database;

  static Future<void> show(BuildContext context) async {
    final database = Provider.of<Database>(context, listen: false);
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => AddSetPage(
          database: database,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  _AddSetPageState createState() => _AddSetPageState();
}

class _AddSetPageState extends State<AddSetPage> {
  final _formKey = GlobalKey<FormState>();
  ScrollController _scrollController = ScrollController();

  Map<String, Widget> _cardList = {};
  Map<String, TextEditingController> _termTECS = {};
  Map<String, TextEditingController> _defTECS = {};
  Map<String, String> _imageUrls = {};

  String _studySetTitle;
  bool _submitted = false;
  bool _isLoaderVisible = false;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 4; ++i) {
      String newFlashcardID = DateTime.now().toIso8601String();
      final FocusNode newFocusNode = FocusNode();
      var termController = TextEditingController();
      var defController = TextEditingController();
      _termTECS[newFlashcardID] = termController;
      _defTECS[newFlashcardID] = defController;
      _imageUrls[newFlashcardID] = "empty";
      _cardList[newFlashcardID] = AddTermDefCard(
        flashcardID: newFlashcardID,
        focusNode: newFocusNode,
        termController: _termTECS[newFlashcardID],
        defController: _defTECS[newFlashcardID],
      );
    }
  }

  @override
  void dispose() {
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
        content: Text('Confirm to create the study set?'),
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
        if (allSetNames.contains(_studySetTitle)) {
          showAlertDialog(context,
              title: "Title already exists",
              content: "Please choose a different study set title!",
              defaultActionText: "OK");
        } else {
          final setID = DateTime.now().toIso8601String();
          final newSet = StudySet(
              setId: setID, name: _studySetTitle, cardAmount: _termTECS.length);
          await widget.database.createSet(newSet);
          context.loaderOverlay.show();
          setState(() {
            _isLoaderVisible = context.loaderOverlay.visible;
          });
          for (String key in _termTECS.keys) {
            String downloadableURL;
            if (_imageUrls[key] != "empty") {
              downloadableURL = await uploadImage(_imageUrls[key]);
            } else {
              downloadableURL = "empty";
            }
            await widget.database.createFlashcard(Flashcard(
                setId: setID,
                flashcardId: key,
                term: _termTECS[key].text,
                definition: _defTECS[key].text,
                imgURL: downloadableURL));
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
          title: Text("New Study Set"),
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
        body: _buildContents(),
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
                  var termController = TextEditingController();
                  var defController = TextEditingController();
                  _termTECS[newFlashcardID] = termController;
                  _defTECS[newFlashcardID] = defController;
                  _imageUrls[newFlashcardID] = "empty";
                  _cardList[newFlashcardID] = AddTermDefCard(
                    flashcardID: newFlashcardID,
                    focusNode: newFocusNode,
                    termController: _termTECS[newFlashcardID],
                    defController: _defTECS[newFlashcardID],
                  );
                  FocusScope.of(context).requestFocus(newFocusNode);

                  _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent + 350,
                      duration: const Duration(milliseconds: 1000),
                      curve: Curves.easeOut);
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

  Widget _buildContents() {
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
        Flexible(
          child: Scrollbar(
            showTrackOnHover: true,
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
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Column(children: [
                                InkWell(
                                  onTap: () => selectImage(key),
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundImage: _imageUrls[key] != "empty"
                                        ? FileImage(File(_imageUrls[key]))
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
        )
      ],
    );
  }

  void _deleteCard(String key) {
    _cardList.remove(key);
    _termTECS.remove(key);
    _defTECS.remove(key);
    _imageUrls.remove(key);
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
