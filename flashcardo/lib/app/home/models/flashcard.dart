import 'package:flutter/foundation.dart';

class Flashcard {
  final String setId;
  final String flashcardId;
  final String term;
  final String definition;
  String imgURL;

  Flashcard(
      {@required this.setId,
      @required this.flashcardId,
      @required this.term,
      @required this.definition,
      this.imgURL});

  factory Flashcard.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }
    final String setId = data["setId"];
    final String flashcardId = data["flashcardId"];
    final String term = data["term"];
    final String definition = data["definition"];
    final String imgURL = data["imgURL"];
    return Flashcard(
      setId: setId,
      flashcardId: flashcardId,
      term: term,
      definition: definition,
      imgURL: imgURL,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "setId": setId,
      "flashcardId": flashcardId,
      "term": term,
      "definition": definition,
      "imgURL": imgURL,
    };
  }
}
