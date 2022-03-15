import 'package:flashcardo/app/home/models/flashcard.dart';
import 'package:flashcardo/app/home/models/quiz_result.dart';
import 'package:flashcardo/app/home/models/study_set.dart';
import 'package:flashcardo/services/api_path.dart';
import 'package:flashcardo/services/firestore_service.dart';
import 'package:flutter/foundation.dart';

abstract class Database {
  Future<void> createSet(StudySet set);
  Future<void> deleteSet(StudySet set);
  Stream<List<StudySet>> setsStream();
  Future<void> createFlashcard(Flashcard flashcard);
  Future<void> deleteFlashcard(String setId, String flashcardId);
  Stream<List<Flashcard>> flashcardsStream(String setId);
  Future<void> saveQuizResult(QuizResult result);
  Future<void> deleteQuizResult(String setId);
  Stream<List<QuizResult>> quizResultsStream();
}

class FirestoreDatabase implements Database {
  FirestoreDatabase({@required this.uid}) : assert(uid != null);
  final String uid;

  final _service = FirestoreService.instance;

  @override
  Future<void> createSet(StudySet set) async => _service.setData(
        path: APIPath.studySet(uid, set.setId),
        data: set.toMap(),
      );

  @override
  Future<void> deleteSet(StudySet set) async => _service.deleteData(
        path1: APIPath.flashcards(uid, set.setId),
        path2: APIPath.studySet(uid, set.setId),
        data: set.toMap(),
      );

  @override
  Stream<List<StudySet>> setsStream() => _service.collectionStream(
        path: APIPath.studySets(uid),
        builder: (data, documentId) => StudySet.fromMap(data, documentId),
      );

  @override
  Future<void> createFlashcard(Flashcard flashcard) async => _service.setData(
        path: APIPath.flashcard(uid, flashcard.setId, flashcard.flashcardId),
        data: flashcard.toMap(),
      );

  @override
  Future<void> deleteFlashcard(String setId, String flashcardId) async =>
      _service.deleteInnerData(
        path: APIPath.flashcard(uid, setId, flashcardId),
      );

  @override
  Stream<List<Flashcard>> flashcardsStream(String setId) =>
      _service.collectionStream(
        path: APIPath.flashcards(uid, setId),
        builder: (data, documentId) => Flashcard.fromMap(data),
      );

  @override
  Future<void> saveQuizResult(QuizResult result) async => _service.setData(
        path: APIPath.quizResult(uid, result.setId, result.resultId),
        data: result.toMap(),
      );

  @override
  Future<void> deleteQuizResult(String setId) async =>
      _service.deleteQuizResultsData(
        path: APIPath.quizResults(uid),
        setID: setId,
      );

  @override
  Stream<List<QuizResult>> quizResultsStream() => _service.collectionStream(
        path: APIPath.quizResults(uid),
        builder: (data, documentId) => QuizResult.fromMap(data),
      );
}
