import 'package:flashcardo/app/home/quiz/question_controller.dart';
import 'package:flashcardo/services/database.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class QuizOptionTile extends StatelessWidget {
  const QuizOptionTile({
    Key key,
    @required double blockSize,
    @required String this.option,
    @required VoidCallback this.ontap,
    @required int this.preferredDuration,
    @required this.questionAmount,
    @required this.database,
    @required this.setId,
  })  : _blockSize = blockSize,
        super(key: key);

  final double _blockSize;
  final String option;
  final VoidCallback ontap;
  final int preferredDuration;
  final int questionAmount;
  final Database database;
  final String setId;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<QuestionController>(
        init: QuestionController(
            preferredDuration, questionAmount, database, setId),
        builder: (qnController) {
          Color getTheRightColor() {
            if (qnController.isAnswered) {
              if (option == qnController.correctAnswer) {
                return Colors.lightGreenAccent[100].withOpacity(1);
              } else if (option == qnController.selectedAnswer &&
                  qnController.selectedAnswer != qnController.correctAnswer) {
                return Colors.red;
              }
            }
            return Colors.white70;
          }

          return InkWell(
            onTap: qnController.isAnswered ? null : ontap,
            child: Container(
              width: _blockSize * 40,
              height: _blockSize * 6,
              padding: EdgeInsets.only(
                  left: _blockSize * 1.3, right: _blockSize * 1.3),
              decoration: BoxDecoration(
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: getTheRightColor(),
                    blurRadius: 5,
                    spreadRadius: 5,
                    offset: Offset(0, 1),
                    blurStyle: BlurStyle.outer,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      option,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: _blockSize * 1.62),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
