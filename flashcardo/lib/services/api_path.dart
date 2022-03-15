class APIPath {
  static String studySet(String uid, String setId) =>
      "users/$uid/studysets/$setId";

  static String flashcards(String uid, String setId) =>
      "users/$uid/studysets/$setId/flashcards";

  static String flashcard(String uid, String setId, String flashcardId) =>
      "users/$uid/studysets/$setId/flashcards/$flashcardId";

  static String studySets(String uid) => "users/$uid/studysets";

  static String quizResult(String uid, String setId, String quizResultId) =>
      "users/$uid/quizresults/$quizResultId";

  static String quizResults(String uid) => "users/$uid/quizresults";
}
