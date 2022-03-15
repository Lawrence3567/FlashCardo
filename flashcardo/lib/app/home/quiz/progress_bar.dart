import 'package:flashcardo/app/home/quiz/question_controller.dart';
import 'package:flashcardo/services/database.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class ProgressBar extends StatelessWidget {
  const ProgressBar({
    Key key,
    @required double blockSize,
    @required this.preferredDuration,
    @required this.questionAmount,
    @required this.database,
    @required this.setId,
  })  : _blockSize = blockSize,
        super(key: key);

  final double _blockSize;
  final int preferredDuration;
  final int questionAmount;
  final Database database;
  final String setId;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: _blockSize * 4,
      decoration: BoxDecoration(
        border: Border.all(color: Color(0x80808080), width: 3),
        borderRadius: BorderRadius.circular(50),
      ),
      child: GetBuilder<QuestionController>(
        init: QuestionController(
            preferredDuration, questionAmount, database, setId),
        builder: (controller) {
          return Stack(
            children: [
              LayoutBuilder(
                builder: (context, constraints) => Container(
                  width: constraints.maxWidth * controller.animation.value != 0
                      ? constraints.maxWidth * controller.animation.value
                      : constraints.maxWidth,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.lightGreen[400], Colors.green[300]],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        preferredDuration != 0
                            ? "${(controller.animation.value * preferredDuration).round()} sec"
                            : "∞",
                        style: TextStyle(
                            color: Colors.blueGrey[700],
                            fontWeight: FontWeight.bold,
                            fontSize: _blockSize * 1.65),
                      ),
                      Image.asset('images/clock.png',
                          color: Colors.blueGrey[700], height: _blockSize * 4),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
