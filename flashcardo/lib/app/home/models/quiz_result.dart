import 'package:flutter/foundation.dart';

class QuizResult {
  final String setId;
  final String resultId;
  final int score;
  final List<String> correctAns;
  final List<String> wrongAns;

  QuizResult(
      {@required this.setId,
      @required this.resultId,
      @required this.score,
      @required this.correctAns,
      @required this.wrongAns});

  factory QuizResult.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    final String setId = data["setId"];
    final String resultId = data["resultId"];
    final int score = data['score'];
    final List<String> correctAns = data['correctAns'].cast<String>();
    final List<String> wrongAns = data["wrongAns"].cast<String>();
    return QuizResult(
      setId: setId,
      resultId: resultId,
      score: score,
      correctAns: correctAns,
      wrongAns: wrongAns,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "setId": setId,
      "resultId": resultId,
      "score": score,
      "correctAns": correctAns,
      "wrongAns": wrongAns,
    };
  }
}
