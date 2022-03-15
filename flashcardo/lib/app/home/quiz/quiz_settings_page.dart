import 'package:flashcardo/app/home/models/study_set.dart';
import 'package:flashcardo/app/home/quiz/take_quiz_page_MCQ.dart';
import 'package:flashcardo/app/home/quiz/take_quiz_page_TOF.dart';
import 'package:flashcardo/services/database.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class QuizSettingsPage extends StatefulWidget {
  const QuizSettingsPage(
      {Key key, @required this.studySet, @required this.database})
      : super(key: key);

  final StudySet studySet;
  final Database database;

  static Future<void> show(BuildContext context,
      {StudySet studySet, Database database}) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuizSettingsPage(
          studySet: studySet,
          database: database,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  _QuizSettingsPageState createState() => _QuizSettingsPageState();
}

class _QuizSettingsPageState extends State<QuizSettingsPage> {
  int _questionAmount = 4;
  int _timerDuration = 30;
  String _stringTimerDuration = "30";
  String _quizFormat = "MCQ";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text("Quiz Settings"),
        backgroundColor: Colors.lightGreen[400],
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
    );
  }

  Widget _buildContents(BuildContext context) {
    MediaQueryData queryData = MediaQuery.of(context);
    final _screenHeight = queryData.size.height;
    final _blockSize = _screenHeight / 100;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          height: _blockSize * 4,
        ),
        Center(
            child: Container(
          decoration: BoxDecoration(
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: (Colors.green[400]).withOpacity(1),
                blurRadius: 5,
                spreadRadius: 5,
                offset: Offset(0, 1),
                blurStyle: BlurStyle.outer,
              ),
            ],
          ),
          child: Card(
            color: Colors.black12,
            child: SizedBox(
              width: 250,
              height: _blockSize * 20,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    "${widget.studySet.name}",
                    overflow: TextOverflow.visible,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: _blockSize * 3.5,
                        fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ),
        )),
        SizedBox(
          width: double.infinity,
          height: _blockSize * 4,
        ),
        Flexible(
          child: SettingsList(
            contentPadding: EdgeInsets.only(top: 10),
            shrinkWrap: true,
            darkBackgroundColor: Colors.grey[900],
            lightBackgroundColor: Colors.grey[900],
            sections: [
              SettingsSection(
                title: 'General',
                tiles: [
                  SettingsTile(
                    title: 'No. of Question',
                    leading: Icon(
                      Icons.format_list_numbered,
                      color: Colors.white,
                    ),
                    trailing: Text(
                      "$_questionAmount",
                      style: TextStyle(
                          color: Colors.lightGreen[300],
                          fontSize: _blockSize * 1.8,
                          fontWeight: FontWeight.w900),
                    ),
                    titleTextStyle: TextStyle(
                      color: Colors.grey[350],
                      fontWeight: FontWeight.w600,
                    ),
                    subtitleTextStyle: TextStyle(
                      color: Colors.grey[350],
                      fontWeight: FontWeight.w500,
                    ),
                    onPressed: (BuildContext context) {
                      selectNumOfQues(context);
                    },
                  ),
                  SettingsTile(
                    title: 'Timer Duration/s',
                    leading: Icon(
                      Icons.timer,
                      color: Colors.white,
                    ),
                    trailing: Text(
                      _stringTimerDuration,
                      style: TextStyle(
                          color: Colors.lightGreen[300],
                          fontSize: _blockSize * 1.8,
                          fontWeight: FontWeight.w900),
                    ),
                    titleTextStyle: TextStyle(
                      color: Colors.grey[350],
                      fontWeight: FontWeight.w600,
                    ),
                    subtitleTextStyle: TextStyle(
                      color: Colors.grey[350],
                      fontWeight: FontWeight.w500,
                    ),
                    onPressed: (BuildContext context) {
                      selectTimerDuration(context);
                    },
                  ),
                ],
              ),
              SettingsSection(
                title: 'Mode',
                tiles: [
                  SettingsTile(
                    title: 'Quiz Format',
                    leading: Icon(
                      Icons.confirmation_number_outlined,
                      color: Colors.white,
                    ),
                    trailing: Text(
                      "$_quizFormat",
                      style: TextStyle(
                          color: Colors.lightGreen[300],
                          fontSize: _blockSize * 1.8,
                          fontWeight: FontWeight.w900),
                    ),
                    titleTextStyle: TextStyle(
                      color: Colors.grey[350],
                      fontWeight: FontWeight.w600,
                    ),
                    subtitleTextStyle: TextStyle(
                      color: Colors.grey[350],
                      fontWeight: FontWeight.w500,
                    ),
                    onPressed: (BuildContext context) {
                      selectQuizFormat(context);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: _blockSize * 15,
        ),
        Center(
          child: Container(
            width: _blockSize * 25,
            height: _blockSize * 8,
            child: ElevatedButton(
              onPressed: () {
                if (_quizFormat == "MCQ") {
                  TakeQuizPageMCQ.show(context,
                      studySet: widget.studySet,
                      quesAmount: _questionAmount,
                      duration: _timerDuration,
                      database: widget.database);
                } else {
                  TakeQuizPageTOF.show(context,
                      studySet: widget.studySet,
                      quesAmount: _questionAmount,
                      duration: _timerDuration,
                      database: widget.database);
                }
                // start quiz
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith(
                  (states) {
                    return Colors.lightGreen[400];
                  },
                ),
                shadowColor: MaterialStateProperty.resolveWith(
                  (states) {
                    return Colors.lightGreen[200];
                  },
                ),
                overlayColor: MaterialStateProperty.resolveWith(
                  (states) {
                    return states.contains(MaterialState.pressed)
                        ? Colors.lightGreenAccent[100]
                        : null;
                  },
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                )),
              ),
              child: Text("Start Quiz",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: _blockSize * 2,
                    fontWeight: FontWeight.w800,
                  )),
            ),
          ),
        )
      ],
    );
  }

  void selectNumOfQues(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.grey[800],
              title: Text(
                "No. of Question",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.lightGreen),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.zero,
                    height: 200,
                    width: 200,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: widget.studySet.cardAmount + 1,
                      itemBuilder: (BuildContext context, int index) {
                        if (index > 0) {
                          return ListTile(
                            title: Text(
                              "$index",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400),
                            ),
                            onTap: () {
                              setState(() {
                                _questionAmount = index;
                              });
                              Navigator.of(context).pop();
                            },
                          );
                        } else {
                          return SizedBox(width: 0, height: 0);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ));
  }

  void selectTimerDuration(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.grey[800],
              title: Text(
                "Timer Duration/s",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.lightGreen),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.zero,
                    height: 200,
                    width: 200,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: 62,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == 15 ||
                            index == 30 ||
                            index == 45 ||
                            index == 60) {
                          return ListTile(
                            title: Text(
                              "${index}s",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400),
                            ),
                            onTap: () {
                              setState(() {
                                _stringTimerDuration = "${index}";
                                _timerDuration = index;
                              });
                              Navigator.of(context).pop();
                            },
                          );
                        } else if (index == 61) {
                          return ListTile(
                            title: Text(
                              "∞",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400),
                            ),
                            onTap: () {
                              setState(() {
                                _stringTimerDuration = "∞";
                                _timerDuration = 0;
                              });
                              Navigator.of(context).pop();
                            },
                          );
                        } else {
                          return SizedBox(width: 0, height: 0);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ));
  }

  void selectQuizFormat(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Colors.grey[800],
              title: Text(
                "Quiz Format",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.lightGreen),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.zero,
                    height: 200,
                    width: 200,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: 2,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == 0) {
                          return ListTile(
                            title: Text(
                              "Multiple Choice Question",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400),
                            ),
                            onTap: () {
                              setState(() {
                                _quizFormat = "MCQ";
                              });
                              Navigator.of(context).pop();
                            },
                          );
                        } else {
                          return ListTile(
                            title: Text(
                              "True or False",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400),
                            ),
                            onTap: () {
                              setState(() {
                                _quizFormat = "TOF";
                              });
                              Navigator.of(context).pop();
                            },
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ));
  }
}
