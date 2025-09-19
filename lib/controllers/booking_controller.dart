import 'package:get/get.dart';
import 'package:primefix_solutions/controllers/auth_controller.dart';

import '../data/models/user_model.dart';

class BookingController extends GetxController {
  final RxList<Booking> userBookings = <Booking>[].obs;
  final RxList<Booking> workerBookings = <Booking>[].obs;
  final Rx<Booking?> activeBooking = Rx<Booking?>(null);

  // Create booking
  Future<String> createBooking({
    required String workerId,
    required String categoryId,
    required String description,
    required Address address,
    required DateTime scheduledDate,
  }) async {
    try {
      final booking = Booking(
        id: generateId(),
        userId: AuthController.to.currentUser.value!.id,
        workerId: workerId,
        categoryId: categoryId,
        description: description,
        serviceAddress: address,
        scheduledDate: scheduledDate,
        status: BookingStatus.pending,
      );

      // Save to database
      await BookingService.createBooking(booking);

      // Send notification to worker
      await NotificationService.sendToWorker(
        workerId,
        'New Job Request',
        'You have a new service request',
      );

      return booking.id;
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  // Worker accepts booking
  Future<void> acceptBooking(String bookingId) async {
    await BookingService.updateStatus(bookingId, BookingStatus.accepted);

    // Notify customer
    final booking = await BookingService.getBooking(bookingId);
    await NotificationService.sendToUser(
      booking.userId,
      'Booking Confirmed',
      'Your service request has been accepted',
    );

    // Start navigation/tracking
    LocationController.to.startTracking();
  }

  // Real-time status updates
  void listenToBookingUpdates(String bookingId) {
    BookingService.getBookingStream(bookingId).listen((booking) {
      activeBooking.value = booking;

      // Handle status changes
      switch (booking.status) {
        case BookingStatus.inProgress:
          Get.snackbar(
            'Service Started',
            'Your service provider has started the work',
          );
          break;
        case BookingStatus.completed:
          Get.toNamed('/rating', arguments: booking);
          break;
        // Handle other status changes
      }
    });
  }
}
