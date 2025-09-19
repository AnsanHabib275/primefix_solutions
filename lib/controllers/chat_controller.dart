class ChatController extends GetxController {
  final RxList<ChatRoom> chatRooms = <ChatRoom>[].obs;
  final RxList<Message> currentMessages = <Message>[].obs;
  final RxString currentChatId = ''.obs;

  void initializeChat(String bookingId) {
    currentChatId.value = bookingId;
    listenToMessages(bookingId);
  }

  void listenToMessages(String chatId) {
    ChatService.getMessagesStream(chatId).listen((messages) {
      currentMessages.value = messages;
      // Mark messages as read
      ChatService.markAsRead(chatId, AuthController.to.currentUser.value!.id);
    });
  }

  Future<void> sendMessage({
    required String content,
    required MessageType type,
    String? attachment,
  }) async {
    if (currentChatId.value.isEmpty) return;

    final message = Message(
      id: generateId(),
      senderId: AuthController.to.currentUser.value!.id,
      content: content,
      type: type,
      timestamp: DateTime.now(),
      isRead: false,
    );

    await ChatService.sendMessage(currentChatId.value, message);

    // Send push notification to other participant
    await NotificationService.sendChatNotification(
      currentChatId.value,
      message,
    );
  }
}
