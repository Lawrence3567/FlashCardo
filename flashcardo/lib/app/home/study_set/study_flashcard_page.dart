import 'package:flashcardo/app/home/models/flashcard.dart';
import 'package:flashcardo/app/home/models/study_set.dart';
import 'package:flashcardo/app/home/study_set/flashcard_view.dart';
import 'package:flashcardo/app/home/study_set/flashcard_backview.dart';
import 'package:flashcardo/services/database.dart';
import 'package:flashcardo/services/preferences_service.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loader_overlay/loader_overlay.dart';

class StudyFlashcardPage extends StatefulWidget {
  const StudyFlashcardPage(
      {Key key, @required this.database, @required this.studySet})
      : super(key: key);

  final Database database;
  final StudySet studySet;

  static Future<void> show(BuildContext context,
      {Database database, StudySet studySet}) async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => StudyFlashcardPage(
          database: database,
          studySet: studySet,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  _StudyFlashcardPageState createState() => _StudyFlashcardPageState();
}

class _StudyFlashcardPageState extends State<StudyFlashcardPage>
    with TickerProviderStateMixin {
  final _preferencesService = PreferencesService();
  int _flashcardFrontColor;
  int _flashcardBackColor;

  List<Flashcard> _flashcards = [];
  bool _firstTime = true;
  bool _isLoaderVisible = false;

  int _currentIndex = 0;

  AnimationController _animationController;
  Animation _animation;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData = MediaQuery.of(context);
    final _screenHeight = queryData.size.height;
    final _blockSize = _screenHeight / 100;

    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 650));
    _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController);
    _animationController.forward();

    return StreamBuilder<List<Flashcard>>(
      stream: widget.database.flashcardsStream(widget.studySet.setId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (_firstTime) {
            _flashcards = snapshot.data;
          }
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
              backgroundColor: Colors.grey[900],
              body: Center(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: _blockSize * 42.4,
                    height: _blockSize * 4,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.chevron_left_rounded,
                          color: Colors.lightGreenAccent[100],
                          size: _blockSize * 4.9,
                        ),
                        label: Text(
                          "",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.lightGreenAccent[100],
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(style: BorderStyle.none),
                        ),
                      ),
                      Opacity(
                          opacity: 0,
                          child: Text(
                            "datadata",
                          )),
                      Opacity(
                          opacity: 0,
                          child: Text(
                            "data",
                          )),
                      Text(
                        "${_currentIndex + 1}/${_flashcards.length}",
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.lightGreenAccent[100],
                            fontSize: _blockSize * 2.4),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: _blockSize * 42.4,
                    height: _blockSize * 2,
                  ),
                  FadeTransition(
                    opacity: _animation,
                    child: SizedBox(
                      width: _blockSize * 42.4,
                      height: _blockSize * 72.69,
                      child: FlipCard(
                        fill: Fill
                            .fillBack, // Fill the back side of the card to make in the same size as the front.
                        direction: FlipDirection.HORIZONTAL, // default
                        front: Dismissible(
                          onDismissed: (direction) => showCard(direction),
                          key: Key(DateTime.now().toIso8601String()),
                          child: FlashcardView(
                            text: _flashcards[_currentIndex].term,
                            fontSize: _blockSize * 4,
                            color: Color(_flashcardFrontColor),
                            elevationColor: Color(_flashcardFrontColor - 1000),
                          ),
                        ),
                        back: FlashcardBackview(
                          text: _flashcards[_currentIndex].definition,
                          fontSize: _blockSize * 3,
                          color: Color(_flashcardBackColor),
                          elevationColor: Color(_flashcardBackColor - 1000),
                          url: _flashcards[_currentIndex].imgURL,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: _blockSize * 42.4,
                    height: _blockSize * 4,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => showPreviousCard(),
                        icon: Icon(
                          Icons.chevron_left_rounded,
                          color: Colors.lightGreenAccent[100],
                          size: _blockSize * 4.9,
                        ),
                        label: Text(
                          "Prev",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.lightGreenAccent[100],
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(style: BorderStyle.none),
                        ),
                      ),
                      Container(
                        width: _blockSize * 4.35,
                        height: _blockSize * 3.8,
                        decoration: BoxDecoration(
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color:
                                  Colors.lightGreenAccent[100].withOpacity(1),
                              blurRadius: 5,
                              spreadRadius: 5,
                              offset: Offset(0, 1),
                              blurStyle: BlurStyle.outer,
                            ),
                          ],
                        ),
                        child: IconButton(
                          iconSize: _blockSize * 3.8,
                          padding: EdgeInsets.zero,
                          onPressed: () async {
                            context.loaderOverlay.show();

                            setState(() {
                              _isLoaderVisible = context.loaderOverlay.visible;
                              _firstTime = false;
                              _currentIndex = 0;
                            });
                            await Future.delayed(Duration(seconds: 2));
                            shuffleFlashcards();
                            if (_isLoaderVisible) {
                              context.loaderOverlay.hide();
                            }
                            setState(() {
                              _isLoaderVisible = context.loaderOverlay.visible;
                            });
                          },
                          icon: Icon(
                            Icons.shuffle_rounded,
                            color: Colors.lightGreenAccent[100],
                          ),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => showNextCard(),
                        icon: Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.lightGreenAccent[100],
                          size: _blockSize * 4.9,
                        ),
                        label: Text(
                          "Next",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Colors.lightGreenAccent[100],
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(style: BorderStyle.none),
                        ),
                      ),
                    ],
                  )
                ],
              )),
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

  void showCard(DismissDirection direction) {
    if (direction == DismissDirection.endToStart) {
      showNextCard();
    } else if (direction == DismissDirection.startToEnd) {
      showPreviousCard();
    }
  }

  void showNextCard() {
    setState(() {
      _firstTime = false;
      _currentIndex =
          (_currentIndex + 1 < _flashcards.length) ? _currentIndex + 1 : 0;
    });
  }

  void showPreviousCard() {
    setState(() {
      _firstTime = false;
      _currentIndex =
          (_currentIndex - 1 >= 0) ? _currentIndex - 1 : _flashcards.length - 1;
    });
  }

  void shuffleFlashcards() {
    setState(() {
      _flashcards.shuffle();
    });
  }

  void _loadSettings() async {
    final settings = await _preferencesService.getSettings();
    setState(() {
      _flashcardFrontColor = settings.flashcardFrontColor ?? 4281348144;
      _flashcardBackColor = settings.flashcardBackColor ?? 4281348144;
    });
  }
}
