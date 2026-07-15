import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Stream of all staff documents (excludes admin role to avoid self-management)
  static Stream<QuerySnapshot<Map<String, dynamic>>> staffStream() {
    return _db
        .collection('users')
        .orderBy('name')
        .snapshots();
  }

  /// Create a new Firebase Auth user and write their profile to Firestore
  static Future<void> addUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    // Create auth account
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
    final uid = cred.user!.uid;

    // Write user profile
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'name': name.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'role': role,
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update an existing staff member's Firestore profile
  static Future<void> updateUser({
    required String uid,
    required String name,
    required String email,
    required String phone,
    required String role,
  }) async {
    await _db.collection('users').doc(uid).update({
      'name': name.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'role': role,
    });
  }

  /// Sends the user a secure Firebase password-reset link. Firebase Auth does
  /// not expose existing passwords to administrators or client applications.
  static Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Set status to 'offline' (deactivate)
  static Future<void> deactivateUser(String uid) async {
    await _db.collection('users').doc(uid).update({'status': 'offline'});
  }

  /// Set status back to 'active'
  static Future<void> activateUser(String uid) async {
    await _db.collection('users').doc(uid).update({'status': 'active'});
  }

  /// Delete the Firestore document (Auth account deletion requires admin SDK)
  static Future<void> deleteUser(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }
}
