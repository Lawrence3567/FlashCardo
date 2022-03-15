import 'package:flutter/foundation.dart';

class StudySet {
  StudySet({@required this.setId, @required this.name, this.cardAmount});
  final String setId;
  final String name;
  final int cardAmount;

  factory StudySet.fromMap(Map<String, dynamic> data, String documentId) {
    if (data == null) {
      return null;
    }
    final String name = data["name"];
    final int cardAmount = data["cardAmount"];
    return StudySet(
      setId: documentId,
      name: name,
      cardAmount: cardAmount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "cardAmount": cardAmount,
    };
  }
}
