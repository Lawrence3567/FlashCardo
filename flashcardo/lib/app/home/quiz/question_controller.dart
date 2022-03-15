import 'package:flashcardo/app/home/models/quiz_result.dart';
import 'package:flashcardo/app/home/quiz/result_page.dart';
import 'package:flashcardo/services/database.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class QuestionController extends GetxController
    with GetSingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation _animation;
  Animation get animation => this._animation;

  PageController _pageController;
  PageController get pageController => this._pageController;

  QuestionController(
      this.preferredDuration, this.questionAmount, this.database, this.setId);

  final int preferredDuration;
  final int questionAmount;
  final Database database;
  final String setId;
  List<String> correctList = [];
  List<String> wrongList = [];

  bool _isAnswered = false;
  bool get isAnswered => this._isAnswered;

  String _correctAnswer;
  String get correctAnswer => this._correctAnswer;

  String _selectedAnswer;
  String get selectedAnswer => this._selectedAnswer;

  RxInt _questionNumber = 1.obs;
  RxInt get questionNumber => this._questionNumber;

  int _numOfCorrectAns = 0;
  int get numOfCorrectAns => this._numOfCorrectAns;

  @override
  void onInit() {
    super.onInit();
    _animationController = AnimationController(
        duration: Duration(seconds: preferredDuration), vsync: this);
    _animation = Tween<double>(begin: 1, end: 0).animate(_animationController)
      ..addListener(() {
        update();
      });
    _animationController.forward().whenComplete(nextQuestion);

    _pageController = PageController();
  }

  @override
  void onClose() {
    _animationController.dispose();
    _pageController.dispose();
    super.onClose();
  }

  void checkAns(String correctAns, String selectedAns,
      GlobalKey<FlipCardState> cardKey, String flashcardName) {
    _isAnswered = true;
    _correctAnswer = correctAns;
    _selectedAnswer = selectedAns;

    if (_correctAnswer == _selectedAnswer) {
      _numOfCorrectAns++;
      correctList.add(flashcardName);
    } else {
      wrongList.add(flashcardName);
    }

    if (preferredDuration != 0) _animationController.stop();
    update();

    cardKey.currentState.toggleCard();

    Future.delayed(Duration(seconds: 3), () {
      nextQuestion();
    });
  }

  void nextQuestion() async {
    if (_questionNumber != questionAmount) {
      _isAnswered = false;
      _pageController.nextPage(
          duration: Duration(milliseconds: 200), curve: Curves.ease);

      if (preferredDuration != 0) {
        _animationController.reset();
        _animationController.forward().whenComplete(nextQuestion);
      }
    } else {
      final resultID = DateTime.now().toIso8601String();
      final newQuizResult = QuizResult(
          setId: setId,
          resultId: resultID,
          score: ((_numOfCorrectAns / questionAmount) * 100).round(),
          correctAns: correctList,
          wrongAns: wrongList);

      await database.saveQuizResult(newQuizResult);

      Get.to(() => ResultPage(
            preferredDuration: preferredDuration,
            questionAmount: questionAmount,
            score: ((_numOfCorrectAns / questionAmount) * 100).round(),
            database: database,
          ));
    }
  }

  void updateQuesNum(int index) {
    _questionNumber.value = index + 1;
  }
}
