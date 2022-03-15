import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  FirestoreService._();
  static final instance = FirestoreService._();

  Future<void> setData(
      {@required String path, @required Map<String, dynamic> data}) async {
    final reference = FirebaseFirestore.instance.doc(path);
    await reference.set(data);
  }

  Stream<List<T>> collectionStream<T>({
    @required String path,
    @required T Function(Map<String, dynamic> data, String documentId) builder,
  }) {
    final reference = FirebaseFirestore.instance.collection(path);
    final snapshots = reference.snapshots();
    return snapshots.map((snapshot) => snapshot.docs
        .map(
          (snapshot) => builder(snapshot.data(), snapshot.id),
        )
        .toList());
  }

  Future<void> deleteData(
      {@required String path1,
      @required String path2,
      @required Map<String, dynamic> data}) async {
    final collection = FirebaseFirestore.instance.collection(path1);
    final snapshots = await collection.get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
    final reference = FirebaseFirestore.instance.doc(path2);
    await reference.delete();
  }

  Future<void> deleteInnerData({@required String path}) async {
    final reference = FirebaseFirestore.instance.doc(path);
    await reference.delete();
  }

  Future<void> deleteQuizResultsData(
      {@required String path, String setID}) async {
    final collection = FirebaseFirestore.instance.collection(path);
    final snapshots = await collection.get();
    for (var doc in snapshots.docs) {
      if (doc.get("setId") == setID) {
        await doc.reference.delete();
      }
    }
  }
}
