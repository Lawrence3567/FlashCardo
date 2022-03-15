import 'package:flashcardo/app/home/models/study_set.dart';
import 'package:flutter/material.dart';

class ChooseQuizListCard extends StatelessWidget {
  const ChooseQuizListCard({
    Key key,
    @required this.studySet,
    @required this.onTap,
  }) : super(key: key);
  final StudySet studySet;
  final VoidCallback onTap;

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
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: Container(
                child: Column(
                  children: [
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
}
