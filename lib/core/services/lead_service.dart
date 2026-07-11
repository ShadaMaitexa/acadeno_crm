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
    Query<Map<String, dynamic>> q = _db.collection('leads').orderBy('createdAt', descending: true);
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
}
