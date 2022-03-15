import 'package:flashcardo/app/home/models/study_set.dart';
import 'package:flashcardo/app/home/quiz/quiz_settings_page.dart';
import 'package:flashcardo/services/database.dart';
import 'package:flutter/material.dart';

import 'choose_quiz_list_card.dart';

class ChooseQuizPage extends StatefulWidget {
  const ChooseQuizPage({Key key, @required this.database}) : super(key: key);

  final Database database;

  static Future<void> show(BuildContext context, {Database database}) async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => ChooseQuizPage(database: database),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  State<ChooseQuizPage> createState() => _ChooseQuizPageState();
}

class _ChooseQuizPageState extends State<ChooseQuizPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Choose a set"),
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
      backgroundColor: Colors.grey[900],
    );
  }

  Widget _buildContents(BuildContext context) {
    MediaQueryData queryData = MediaQuery.of(context);
    final _screenHeight = queryData.size.height;
    final _blockSize = _screenHeight / 100;

    return StreamBuilder<List<StudySet>>(
      stream: widget.database.setsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final studySets = snapshot.data;
          final children = studySets
              .map((studyset) => ChooseQuizListCard(
                    studySet: studyset,
                    onTap: () => QuizSettingsPage.show(
                      context,
                      studySet: studyset,
                      database: widget.database,
                    ), //go to QuizSettingsPage
                  ))
              .toList();
          if (snapshot.data.isEmpty)
            return Center(
              child: Material(
                color: Colors.grey[900],
                child: Container(
                  width: _blockSize * 30,
                  height: _blockSize * 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.grey[400],
                        blurRadius: 5,
                        spreadRadius: 50,
                        offset: Offset(0, 1),
                        blurStyle: BlurStyle.outer,
                      ),
                    ],
                  ),
                  child: Image(
                    colorBlendMode: BlendMode.modulate,
                    color: Colors.grey[900],
                    image: AssetImage("images/listEmpty.png"),
                  ),
                ),
              ),
            );
          return Scrollbar(child: ListView(primary: false, children: children));
        }
        if (snapshot.hasError) {
          return Center(child: Text("Some errors occured!"));
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
