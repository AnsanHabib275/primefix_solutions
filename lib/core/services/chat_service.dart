class RealtimeChatService {
  static void initializeChat(String chatRoomId) {
    FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .listen((snapshot) {
          final messages =
              snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList();

          ChatController.to.currentMessages.value = messages;
        });
  }

  static Future<void> sendMessage({
    required String chatRoomId,
    required Message message,
  }) async {
    // Add to Firestore
    await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(message.toJson());

    // Update last message in chat room
    await FirebaseFirestore.instance
        .collection('chat_rooms')
        .doc(chatRoomId)
        .update({
          'last_message': message.toJson(),
          'updated_at': FieldValue.serverTimestamp(),
        });

    // Send push notification
    await sendChatPushNotification(chatRoomId, message);
  }
}
