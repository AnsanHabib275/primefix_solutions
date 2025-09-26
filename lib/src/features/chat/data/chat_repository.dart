import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRepository {
  final _db = FirebaseFirestore.instance;

  String roomId(String a, String b) => (a.compareTo(b) < 0) ? '${a}_$b' : '${b}_$a';

  Stream<List<Map<String, dynamic>>> watchMessages(String a, String b) {
    final id = roomId(a, b);
    return _db
        .collection('chats')
        .doc(id)
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .limit(100)
        .snapshots()
        .map((s) => s.docs.map((d) => d.data()).toList());
  }

  Future<void> send(String from, String to, String text) async {
    final id = roomId(from, to);
    final msgRef = _db.collection('chats').doc(id).collection('messages').doc();
    await msgRef.set({
      'id': msgRef.id,
      'from': from,
      'to': to,
      'text': text,
      'sentAt': FieldValue.serverTimestamp(),
      'read': false
    });
    await _db.collection('chats').doc(id).set({
      'id': id,
      'a': from,
      'b': to,
      'updatedAt': FieldValue.serverTimestamp(),
      'lastMessage': text
    }, SetOptions(merge: true));
  }
}
