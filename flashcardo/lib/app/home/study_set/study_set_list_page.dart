import 'package:flashcardo/app/home/models/study_set.dart';
import 'package:flashcardo/app/home/study_set/add_set_page.dart';
import 'package:flashcardo/app/home/study_set/study_flashcard_page.dart';
import 'package:flashcardo/app/home/study_set/study_set_list_card.dart';
import 'package:flashcardo/services/database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StudySetListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Study Sets"),
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 65.0),
        child: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Colors.white,
          onPressed: () => AddSetPage.show(context),
          elevation: 50,
          tooltip: "Create a new study set",
        ),
      ),
    );
  }

  Widget _buildContents(BuildContext context) {
    MediaQueryData queryData = MediaQuery.of(context);
    final _screenHeight = queryData.size.height;
    final _blockSize = _screenHeight / 100;

    final database = Provider.of<Database>(context, listen: false);
    return StreamBuilder<List<StudySet>>(
      stream: database.setsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final studySets = snapshot.data;
          final children = studySets
              .map((studyset) => StudySetListCard(
                    context: context,
                    studySet: studyset,
                    database: database,
                    onTap: () => StudyFlashcardPage.show(
                      context,
                      database: database,
                      studySet: studyset,
                    ), //go to StudyFlashcardPage
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
