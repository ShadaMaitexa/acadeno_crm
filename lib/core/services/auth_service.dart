import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _defaultAdminEmail = 'admin@acadeno.in';
  static const String _defaultAdminPassword = 'admin123';

  static User? get currentUser => _auth.currentUser;

  /// Sign in and return the user's role ('admin' or their assigned role name).
  /// For the very first admin login the Firestore document is bootstrapped automatically.
  static Future<String> signIn(String email, String password) async {
    final trimmedEmail = email.trim();
    final trimmedPassword = password.trim();

    if (trimmedEmail == _defaultAdminEmail &&
        trimmedPassword == _defaultAdminPassword) {
      try {
        final cred = await _auth.signInWithEmailAndPassword(
          email: trimmedEmail,
          password: trimmedPassword,
        );
        return await _bootstrapAdminUser(cred.user!.uid, trimmedEmail);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          final cred = await _auth.createUserWithEmailAndPassword(
            email: trimmedEmail,
            password: trimmedPassword,
          );
          return await _bootstrapAdminUser(cred.user!.uid, trimmedEmail);
        }
        rethrow;
      }
    }

    final cred = await _auth.signInWithEmailAndPassword(
      email: trimmedEmail,
      password: trimmedPassword,
    );
    final uid = cred.user!.uid;

    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) {
      // Bootstrap admin document on first ever login
      await _db.collection('users').doc(uid).set({
        'uid': uid,
        'name': 'Admin',
        'email': trimmedEmail,
        'phone': '',
        'role': 'admin',
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return 'admin';
    }

    return (doc.data()?['role'] as String?) ?? 'staff';
  }

  static Future<String> _bootstrapAdminUser(String uid, String email) async {
    final docRef = _db.collection('users').doc(uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        'uid': uid,
        'name': 'Admin',
        'email': email,
        'phone': '',
        'role': 'admin',
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return 'admin';
  }

  static Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  static Future<Map<String, dynamic>?> getUserProfile() async {
    final uid = currentUser?.uid;
    if (uid == null) return null;
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }
}
