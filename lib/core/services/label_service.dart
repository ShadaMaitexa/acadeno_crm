import 'package:cloud_firestore/cloud_firestore.dart';

class LabelService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final _labelsRef = _db.collection('labels');

  static Stream<QuerySnapshot<Map<String, dynamic>>> labelsStream() {
    return _labelsRef.orderBy('createdAt', descending: true).snapshots();
  }

  static Future<void> addLabel({
    required String name,
    required String description,
  }) async {
    await _labelsRef.add({
      'name': name.trim(),
      'description': description.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updateLabel({
    required String id,
    required String name,
    required String description,
  }) async {
    await _labelsRef.doc(id).update({
      'name': name.trim(),
      'description': description.trim(),
    });
  }

  static Future<void> deleteLabel(String id) async {
    await _labelsRef.doc(id).delete();
  }
}
