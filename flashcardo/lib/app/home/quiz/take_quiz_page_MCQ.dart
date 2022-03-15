import 'dart:math';

import 'package:flashcardo/app/home/models/flashcard.dart';
import 'package:flashcardo/app/home/models/study_set.dart';
import 'package:flashcardo/app/home/quiz/progress_bar.dart';
import 'package:flashcardo/app/home/quiz/question_controller.dart';
import 'package:flashcardo/app/home/quiz/quiz_question_card_MCQ.dart';
import 'package:flashcardo/services/database.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TakeQuizPageMCQ extends StatefulWidget {
  const TakeQuizPageMCQ(
      {Key key,
      @required this.studySet,
      @required this.database,
      @required this.questionAmount,
      @required this.preferredDuration})
      : super(key: key);

  final StudySet studySet;
  final Database database;
  final int questionAmount;
  final int preferredDuration;

  static Future<void> show(BuildContext context,
      {StudySet studySet,
      int quesAmount,
      int duration,
      Database database}) async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => new TakeQuizPageMCQ(
          studySet: studySet,
          database: database,
          questionAmount: quesAmount,
          preferredDuration: duration,
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  State<TakeQuizPageMCQ> createState() => _TakeQuizPageMCQState();
}

class _TakeQuizPageMCQState extends State<TakeQuizPageMCQ> {
  List<Flashcard> _flashcards = [];
  List<String> _definitions = [];
  List<List<String>> _optionList = [];
  bool _firstTime = true;
  List<GlobalKey<FlipCardState>> _cardKeys = [];

  @override
  void dispose() {
    Get.delete<QuestionController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _buildContents(context),
    );
  }

  Widget _buildContents(BuildContext context) {
    MediaQueryData queryData = MediaQuery.of(context);
    final _screenHeight = queryData.size.height;
    final _blockSize = _screenHeight / 100;
    QuestionController _quesController = Get.put(QuestionController(
        widget.preferredDuration,
        widget.questionAmount,
        widget.database,
        widget.studySet.setId));

    return Stack(
      children: [
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProgressBar(
                  blockSize: _blockSize,
                  preferredDuration: widget.preferredDuration,
                  questionAmount: widget.questionAmount,
                  database: widget.database,
                  setId: widget.studySet.setId,
                ),
                SizedBox(height: _blockSize * 2),
                Obx(
                  () => Text.rich(
                    TextSpan(
                        text: "Q${_quesController.questionNumber.value}",
                        style: TextStyle(
                            fontSize: _blockSize * 3, color: Colors.white),
                        children: [
                          TextSpan(
                            text: "/${widget.questionAmount}",
                            style: TextStyle(
                                fontSize: _blockSize * 2,
                                color: Colors.white70),
                          ),
                        ]),
                  ),
                ),
                Divider(
                  thickness: 2,
                  color: Colors.grey,
                ),
                StreamBuilder<Object>(
                    stream:
                        widget.database.flashcardsStream(widget.studySet.setId),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        _flashcards = snapshot.data;

                        if (_firstTime) {
                          _flashcards.shuffle();
                          for (int i = 0; i < _flashcards.length; ++i) {
                            _definitions.add(_flashcards[i].definition);
                          }
                          for (int i = 0; i < widget.questionAmount; ++i) {
                            final _random = new Random();
                            List<String> tempList = [];
                            tempList.add(_flashcards[i].definition);
                            for (int j = 0; j < 3; ++j) {
                              String element;
                              do {
                                element = _definitions[
                                    _random.nextInt(_definitions.length)];
                              } while (element == _flashcards[i].definition ||
                                  tempList.contains(element));

                              tempList.add(element);
                            }
                            _cardKeys.add(GlobalKey<FlipCardState>());
                            tempList.shuffle(_random);
                            _optionList.add(tempList);
                          }
                          _firstTime = false;
                        }

                        return Expanded(
                          child: PageView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            controller: _quesController.pageController,
                            onPageChanged: _quesController.updateQuesNum,
                            itemCount: widget.questionAmount,
                            itemBuilder: (context, index) =>
                                QuizQuestionCardMCQ(
                              blockSize: _blockSize,
                              question: _flashcards[index].term,
                              answer: _flashcards[index].definition,
                              optionList: _optionList[index],
                              preferredDuration: widget.preferredDuration,
                              questionAmount: widget.questionAmount,
                              cardKey: _cardKeys[index],
                              database: widget.database,
                              setId: widget.studySet.setId,
                              flashcardName: _flashcards[index].term,
                            ),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text("Some errors occured!"));
                      }
                      return Center(child: CircularProgressIndicator());
                    }),
              ],
            ),
          ),
        )
      ],
    );
  }
}
