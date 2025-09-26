import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());
final authStateProvider = StreamProvider<User?>((ref) => FirebaseAuth.instance.authStateChanges());
final appUserProvider = StreamProvider<AppUser?>((ref) => AuthRepository().watchCurrentAppUser());

class AuthRepository {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Future<void> startPhoneAuth(String phone, {required void Function(String verId) onCodeSent}) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (cred) async {
        await _auth.signInWithCredential(cred);
        await _ensureAppUserDoc();
      },
      verificationFailed: (e) => throw e,
      codeSent: (verificationId, _) => onCodeSent(verificationId),
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<void> confirmOtp(String verificationId, String smsCode) async {
    final cred = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);
    await _auth.signInWithCredential(cred);
    await _ensureAppUserDoc();
  }

  Future<void> _ensureAppUserDoc() async {
    final uid = _auth.currentUser!.uid;
    final doc = _db.collection('users').doc(uid);
    final snap = await doc.get();
    if (!snap.exists) {
      await doc.set({
        'uid': uid,
        'role': 'customer',
        'createdAt': FieldValue.serverTimestamp(),
        'name': _auth.currentUser!.phoneNumber,
        'phone': _auth.currentUser!.phoneNumber,
        'fcmTokens': [],
      });
    }
  }

  Stream<AppUser?> watchCurrentAppUser() async* {
    final user = _auth.currentUser;
    if (user == null) {
      yield null;
      return;
    }
    yield* _db.collection('users').doc(user.uid).snapshots().map(
          (d) => d.exists ? AppUser.fromMap(d.data()!) : null,
        );
  }

  Future<void> updateRole(String role) async {
    final uid = _auth.currentUser!.uid;
    await _db.collection('users').doc(uid).set({'role': role}, SetOptions(merge: true));
  }

  Future<void> signOut() => _auth.signOut();
}

class AppUser {
  final String uid;
  final String role;
  final String? name;
  final String? phone;
  AppUser({required this.uid, required this.role, this.name, this.phone});
  factory AppUser.fromMap(Map<String, dynamic> m) =>
      AppUser(uid: m['uid'], role: m['role'] ?? 'customer', name: m['name'], phone: m['phone']);
}
