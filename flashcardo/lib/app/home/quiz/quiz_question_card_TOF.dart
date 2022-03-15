import 'package:flashcardo/app/home/quiz/question_controller.dart';
import 'package:flashcardo/app/home/quiz/quiz_option_tile.dart';
import 'package:flashcardo/app/home/study_set/flashcard_view.dart';
import 'package:flashcardo/services/database.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuizQuestionCardTOF extends StatelessWidget {
  QuizQuestionCardTOF({
    Key key,
    @required double blockSize,
    @required this.question,
    @required this.answer,
    @required this.option,
    @required this.preferredDuration,
    @required this.questionAmount,
    @required this.cardKey,
    @required this.database,
    @required this.setId,
    this.flashcardName,
  })  : _blockSize = blockSize,
        super(key: key);

  final double _blockSize;
  final String question;
  final String answer;
  final String option;
  final int preferredDuration;
  final int questionAmount;
  final GlobalKey<FlipCardState> cardKey;
  final Database database;
  final String setId;
  String flashcardName;

  @override
  Widget build(BuildContext context) {
    QuestionController _controller = Get.put(
        QuestionController(preferredDuration, questionAmount, database, setId));

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Term",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[300],
                  fontSize: _blockSize * 1.8),
            ),
          ],
        ),
        SizedBox(height: _blockSize * 2),
        SizedBox(
          width: _blockSize * 40,
          height: _blockSize * 16,
          child: FlipCard(
            key: cardKey,
            speed: 800,
            flipOnTouch: false,
            fill: Fill
                .fillBack, // Fill the back side of the card to make in the same size as the front.
            direction: FlipDirection.HORIZONTAL, // default
            front: FlashcardView(
              text: question,
              fontSize: _blockSize * 2.8,
              color: Colors.grey[850],
              elevationColor: Color(0x808080),
            ),

            back: FlashcardView(
              text: answer,
              fontSize: _blockSize * 2.4,
              color: Colors.grey[850],
              elevationColor: Colors.deepPurple[700],
            ),
          ),
        ),
        SizedBox(
          width: _blockSize * 42.4,
          height: _blockSize * 2,
        ),
        Text(
          "=",
          style: TextStyle(
              color: Colors.lightGreenAccent[100],
              fontWeight: FontWeight.w900,
              fontSize: _blockSize * 4.5),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              "Definition",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[300],
                  fontSize: _blockSize * 1.8),
            ),
          ],
        ),
        SizedBox(
          width: _blockSize * 42.4,
          height: _blockSize * 2,
        ),
        SizedBox(
          width: _blockSize * 40,
          height: _blockSize * 16,
          child: FlipCard(
            speed: 800,
            flipOnTouch: false,
            fill: Fill
                .fillBack, // Fill the back side of the card to make in the same size as the front.
            direction: FlipDirection.HORIZONTAL, // default
            front: FlashcardView(
              text: option,
              fontSize: _blockSize * 2.4,
              color: Colors.grey[850],
              elevationColor: Colors.deepPurple[700],
            ),
            back: FlashcardView(
              text: option,
              fontSize: _blockSize * 2.4,
              color: Colors.grey[850],
              elevationColor: Colors.deepPurple[700],
            ),
          ),
        ),
        SizedBox(
          width: _blockSize * 42.4,
          height: _blockSize * 6.5,
        ),
        QuizOptionTile(
          blockSize: _blockSize,
          option: "True",
          ontap: () => _controller.checkAns(answer == option ? "True" : "False",
              "True", cardKey, flashcardName),
          preferredDuration: preferredDuration,
          questionAmount: questionAmount,
          database: database,
          setId: setId,
        ),
        SizedBox(height: _blockSize * 4),
        QuizOptionTile(
          blockSize: _blockSize,
          option: "False",
          ontap: () => _controller.checkAns(answer == option ? "True" : "False",
              "False", cardKey, flashcardName),
          preferredDuration: preferredDuration,
          questionAmount: questionAmount,
          database: database,
          setId: setId,
        ),
      ],
    );
  }
}
