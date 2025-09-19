class PaymentService {
  // Stripe Integration
  static Future<PaymentIntent> createPaymentIntent({
    required double amount,
    required String currency,
    required String customerId,
  }) async {
    final response = await ApiService.post(
      '/payments/create-intent',
      data: {
        'amount': (amount * 100).toInt(), // Convert to cents
        'currency': currency,
        'customer_id': customerId,
      },
    );

    return PaymentIntent.fromJson(response.data);
  }

  // Local Payment Gateways (JazzCash, EasyPaisa)
  static Future<String> initiateLocalPayment({
    required double amount,
    required String method, // 'jazzcash' or 'easypaisa'
    required String phoneNumber,
  }) async {
    final response = await ApiService.post(
      '/payments/local',
      data: {'amount': amount, 'method': method, 'phone': phoneNumber},
    );

    return response.data['transaction_id'];
  }

  static Future<PaymentStatus> checkPaymentStatus(String transactionId) async {
    final response = await ApiService.get('/payments/status/$transactionId');
    return PaymentStatus.fromString(response.data['status']);
  }
}
