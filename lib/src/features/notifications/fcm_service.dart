import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> initFcmToken(String uid) async {
  await FirebaseMessaging.instance.requestPermission();
  final token = await FirebaseMessaging.instance.getToken();
  if (token != null) {
    await FirebaseFirestore.instance.collection('users').doc(uid)
      .set({'fcmTokens': FieldValue.arrayUnion([token])}, SetOptions(merge: true));
  }
}
