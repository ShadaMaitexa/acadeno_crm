import 'dart:convert';

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
    bool converted = false,
    String? deviceLogKey,
  }) async {
    final doc = await _db.collection('call_logs').add({
      'name': name.trim(),
      'phone': phone.trim(),
      'dateTime': dateTime,
      'duration': duration,
      'callType': callType,
      'tag': tag,
      'converted': converted,
      if (deviceLogKey != null) 'deviceLogKey': deviceLogKey,
      'userId': _uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  static Future<void> updateTag(String logId, String? tag) async {
    await _db.collection('call_logs').doc(logId).update({'tag': tag});
  }

  static Future<void> updateConverted(String logId, bool converted) async {
    await _db.collection('call_logs').doc(logId).update({
      'converted': converted,
    });
  }

  static Future<void> updateNotes(String logId, String notes) async {
    await _db.collection('call_logs').doc(logId).update({'notes': notes.trim()});
  }

  /// Returns the saved Firestore record for each device-call key. This lets
  /// device logs retain their CRM fields after the screen is reopened.
  static Future<Map<String, Map<String, dynamic>>> deviceLogStates() async {
    final snapshot = await _db
        .collection('call_logs')
        .where('userId', isEqualTo: _uid)
        .get();

    return {
      for (final doc in snapshot.docs)
        if (doc.data()['deviceLogKey'] case final String key)
          key: {
            'id': doc.id,
            'converted': doc.data()['converted'] as bool? ?? false,
            'tag': doc.data()['tag'] as String?,
            'notes': doc.data()['notes'] as String? ?? '',
          },
    };
  }

  static Future<void> deleteLog(String logId) async {
    await _db.collection('call_logs').doc(logId).delete();
  }

  /// Batch-delete multiple call log documents atomically.
  static Future<void> deleteLogs(List<String> ids) async {
    if (ids.isEmpty) return;
    final batch = _db.batch();
    for (final id in ids) {
      batch.delete(_db.collection('call_logs').doc(id));
    }
    await batch.commit();
  }

  /// A stable, per-call identifier for call entries provided by Android.
  /// It is intentionally based on the raw timestamp and call metadata rather
  /// than the display date, which is locale-dependent.
  static String deviceLogKey({
    required String phone,
    required int timestamp,
    required String duration,
    required String callType,
  }) {
    final value = '$timestamp|$phone|$duration|$callType';
    return base64Url.encode(utf8.encode(value)).replaceAll('=', '');
  }

  /// Device call history cannot normally be modified by a non-default Android
  /// dialer. Store a user-scoped tombstone so a deleted entry never reappears
  /// in this app when the device history is refreshed.
  static Future<Set<String>> deletedDeviceLogKeys() async {
    final snapshot = await _db
        .collection('deleted_call_logs')
        .where('userId', isEqualTo: _uid)
        .get();
    return snapshot.docs
        .map((doc) => doc.data()['deviceLogKey'] as String?)
        .whereType<String>()
        .toSet();
  }

  static Future<void> markDeviceLogsDeleted(Iterable<String> keys) async {
    final uniqueKeys = keys.toSet().toList();
    for (var start = 0; start < uniqueKeys.length; start += 500) {
      final batch = _db.batch();
      final end = (start + 500).clamp(0, uniqueKeys.length);
      for (final key in uniqueKeys.sublist(start, end)) {
        batch.set(_db.collection('deleted_call_logs').doc(key), {
          'userId': _uid,
          'deviceLogKey': key,
          'deletedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    }
  }
}
