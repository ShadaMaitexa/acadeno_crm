import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LeadService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String get _uid => _auth.currentUser?.uid ?? 'unknown';

  /// Stream of leads filtered by type
  static Stream<QuerySnapshot<Map<String, dynamic>>> leadsStream({
    String? type,
  }) {
    Query<Map<String, dynamic>> q = _db.collection('leads');
    q = q.where('createdBy', isEqualTo: _uid);
    if (type != null) {
      q = q.where('type', isEqualTo: type);
    }
    return q.snapshots();
  }

  static Future<void> addLead({
    required String name,
    required String phone,
    required String email,
    String notes = '',
    String type = 'hot',
  }) async {
    await _db.collection('leads').add({
      'name': name.trim(),
      'phone': phone.trim(),
      'email': email.trim(),
      'notes': notes.trim(),
      'type': type,
      'createdBy': _uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> deleteLead(String id) async {
    await _db.collection('leads').doc(id).delete();
  }

  static Future<void> updateLead(String id, Map<String, dynamic> data) async {
    await _db.collection('leads').doc(id).update(data);
  }

  /// Creates a lead from a device call, or changes the existing lead from the
  /// same call to the newly selected queue.
  static Future<void> moveCallLogToLead({
    required String sourceCallKey,
    required String name,
    required String phone,
    required String dateTime,
    required String duration,
    required String callType,
    required String type,
  }) async {
    final existing = await _db
        .collection('leads')
        .where('sourceCallKey', isEqualTo: '$_uid:$sourceCallKey')
        .limit(1)
        .get();

    final data = <String, dynamic>{
      'name': name.trim(),
      'phone': phone.trim(),
      'dateTime': dateTime,
      'duration': duration,
      'callType': callType,
      'type': type,
      'createdBy': _uid,
      'sourceCallKey': '$_uid:$sourceCallKey',
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (existing.docs.isEmpty) {
      await _db.collection('leads').add({
        ...data,
        'email': '',
        'notes': '',
        'converted': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else {
      await existing.docs.first.reference.update(data);
    }
  }

  static Future<void> removeCallLogLead(String sourceCallKey) async {
    final existing = await _db
        .collection('leads')
        .where('sourceCallKey', isEqualTo: '$_uid:$sourceCallKey')
        .get();
    final batch = _db.batch();
    for (final doc in existing.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
