import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CallLogService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String get _uid => _auth.currentUser?.uid ?? 'unknown';

  static Stream<QuerySnapshot<Map<String, dynamic>>> callLogsStream() {
    return _db
        .collection('call_logs')
        .where('userId', isEqualTo: _uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static Future<String> addCallLog({
    required String name,
    required String phone,
    required String dateTime,
    required String duration,
    required String callType,
    String? tag,
  }) async {
    final doc = await _db.collection('call_logs').add({
      'name': name.trim(),
      'phone': phone.trim(),
      'dateTime': dateTime,
      'duration': duration,
      'callType': callType,
      'tag': tag,
      'userId': _uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  static Future<void> updateTag(String logId, String? tag) async {
    await _db.collection('call_logs').doc(logId).update({'tag': tag});
  }

  static Future<void> deleteLog(String logId) async {
    await _db.collection('call_logs').doc(logId).delete();
  }
}
