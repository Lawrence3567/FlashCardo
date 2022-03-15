import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flashcardo/app/home/models/study_set.dart';
import 'package:flashcardo/app/home/study_set/constants.dart';
import 'package:flashcardo/app/home/study_set/edit_set_page.dart';
import 'package:flashcardo/common_widget/show_alert_dialog.dart';
import 'package:flashcardo/services/database.dart';
import 'package:flutter/material.dart';

class StudySetListCard extends StatelessWidget {
  const StudySetListCard(
      {Key key,
      @required this.studySet,
      @required this.onTap,
      @required this.database,
      @required this.context})
      : super(key: key);
  final StudySet studySet;
  final VoidCallback onTap;
  final BuildContext context;

  final Database database;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 25, bottom: 0, left: 40, right: 40),
      child: Card(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.white70, width: 2),
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
          color: Colors.black12,
          child: InkWell(
            splashColor: Colors.blueGrey,
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 18),
              child: Container(
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment(1, 0.05),
                      heightFactor: 0.5,
                      child: PopupMenuButton<String>(
                        onSelected: (choice) => choiceAction(choice, context),
                        iconSize: 28,
                        icon: Icon(
                          Icons.more_vert,
                          color: Colors.white,
                        ),
                        itemBuilder: (BuildContext context) {
                          return Constants.choices.map((String choice) {
                            return PopupMenuItem<String>(
                              value: choice,
                              child: Text(choice),
                            );
                          }).toList();
                        },
                      ),
                    ),
                    Text(
                      studySet.name,
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.lightGreenAccent[100],
                        fontWeight: FontWeight.w900,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Cards: ${studySet.cardAmount.toString()}",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.green[100],
                        fontWeight: FontWeight.w900,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  Future<void> choiceAction(String choice, BuildContext context) async {
    if (choice == Constants.DeleteSet) {
      final confirmDeleteSet = await showAlertDialog(
        context,
        title: "Delete Study Set",
        content: "Confirm to delete this study set?",
        cancelActionText: "Cancel",
        defaultActionText: "Yes",
      );
      if (confirmDeleteSet == true) {
        try {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Study Set Deleted Successfully!',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          );
          await database.deleteSet(studySet);
          await database.deleteQuizResult(studySet.setId);
        } on FirebaseException catch (e) {
          print(e);
        }
      }
    } else if (choice == Constants.EditSet) {
      try {
        await EditSetPage.show(context, database: database, studySet: studySet);
      } catch (e) {
        print(e);
      }
    }
  }
}
