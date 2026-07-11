import 'package:cloud_firestore/cloud_firestore.dart';

class RoleService {
  static final _rolesRef =
      FirebaseFirestore.instance.collection('roles');

  /// Stream of all roles ordered by name
  static Stream<QuerySnapshot<Map<String, dynamic>>> rolesStream() {
    return _rolesRef.orderBy('name').snapshots();
  }

  /// One-time fetch of role names as a list of strings
  static Future<List<String>> getRoleNames() async {
    final snap = await _rolesRef.orderBy('name').get();
    return snap.docs.map((d) => d.data()['name'] as String).toList();
  }

  static Future<void> addRole({
    required String name,
    required String description,
  }) async {
    await _rolesRef.add({
      'name': name.trim(),
      'description': description.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updateRole({
    required String id,
    required String name,
    required String description,
  }) async {
    await _rolesRef.doc(id).update({
      'name': name.trim(),
      'description': description.trim(),
    });
  }

  static Future<void> deleteRole(String id) async {
    await _rolesRef.doc(id).delete();
  }
}
