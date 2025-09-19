class NotificationService {
  static Future<void> initialize() async {
    await FirebaseMessaging.instance.requestPermission();

    // Get FCM token
    final token = await FirebaseMessaging.instance.getToken();
    await _saveTokenToDatabase(token);

    // Listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen(_saveTokenToDatabase);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
  }

  static Future<void> sendJobNotification({
    required String workerId,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    await ApiService.post(
      '/notifications/send',
      data: {
        'recipient_id': workerId,
        'title': title,
        'body': body,
        'data': data,
        'type': 'job_request',
      },
    );
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    // Show in-app notification
    Get.snackbar(
      message.notification?.title ?? 'Notification',
      message.notification?.body ?? '',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
    );

    // Handle different notification types
    switch (message.data['type']) {
      case 'job_request':
        _handleJobRequest(message.data);
        break;
      case 'chat_message':
        _handleChatMessage(message.data);
        break;
      case 'booking_update':
        _handleBookingUpdate(message.data);
        break;
    }
  }
}
