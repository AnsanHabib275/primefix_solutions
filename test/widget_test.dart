// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
//
// import 'package:primefix_solutions/main.dart';
//
// void main() {
//   testWidgets('Counter increments smoke test', (WidgetTester tester) async {
//     // Build our app and trigger a frame.
//     await tester.pumpWidget(const MyApp());
//
//     // Verify that our counter starts at 0.
//     expect(find.text('0'), findsOneWidget);
//     expect(find.text('1'), findsNothing);
//
//     // Tap the '+' icon and trigger a frame.
//     await tester.tap(find.byIcon(Icons.add));
//     await tester.pump();
//
//     // Verify that our counter has incremented.
//     expect(find.text('0'), findsNothing);
//     expect(find.text('1'), findsOneWidget);
//   });
// }
// Widget Tests
// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:primefix_solutions/controllers/booking_controller.dart';
// import 'package:primefix_solutions/data/models/address_model.dart';
// import 'package:primefix_solutions/data/models/worker_model.dart';
//
// class WorkerCardTest {
//   testWidgets('WorkerCard displays worker information correctly', (WidgetTester tester)) async {
//   final worker = Worker(
//   id: '1',
//   name: 'John Doe',
//   category: 'electric  is,
//   rating: 4.5,
//     islyRate: 800,
//   isOnline: true, userId: ''  isilyRate: null, currentLocation: null, workingHours: null, lastSeen: null, hourlyRate:nulll, dailyRate: null,
//   );
//
//   await tester.pumpWidget(MaterialApp(
//   home: WorkerCard(worker: worker),
//   ));
//
//   expect(find.text('John Doe'), findsOneWidget);
//   expect(find.text('Rs. 800/hour'), findsOneWidget);
//   expect(find.byIcon(Icons.star), findsOneWidget);
//   }) {
//     // TODO: implement testWidgets
//     throw UnimplementedError();
//   }
// }
//
// // Integration Tests
// class BookingFlowTest {
//   testWidgets('Complete booking flow', (WidgetTester tester) async {
//   // Setup mock services
//   Get.put<BookingController>(MockBookingController());
//
//   await tester.pumpWidget(MyApp());
//
//   // Navigate to worker profile
//   await tester.tap(find.byKey(Key('worker_card_0')));
//   await tester.pumpAndSettle();
//
//   // Tap book now
//   await tester.tap(find.text('Book Now'));
//   await tester.pumpAndSettle();
//
//   // Fill booking form
//   await tester.enterText(find.byKey(Key('description_field')), 'Fix broken switch');
//   await tester.tap(find.byKey(Key('date_picker')));
//   await tester.pumpAndSettle();
//
//   // Confirm booking
//   await tester.tap(find.text('Confirm Booking'));
//   await tester.pumpAndSettle();
//
//   // Verify booking success
//   expect(find.text('Booking Confirmed'), findsOneWidget);
//   }) {
//     // TODO: implement testWidgets
//     throw UnimplementedError();
//   }
// }
//
// // Unit Tests
// class BookingControllerTest {
//   group('BookingController', () ){
//   late BookingController controller;
//
//   setUp(() {
//   controller = BookingController();
//   });
//
//   test('createBooking should add booking to list', () async {
//   // Arrange
//   final initialCount = controller.userBookings.length;
//
//   // Act
//   await controller.createBooking(
//   workerId: 'worker1',
//   categoryId: 'electrician',
//   description: 'Test booking',
//   address: Address(city: '',street: 'Test St', state: ''),
//   scheduledDate: DateTime.now(),
//   );
//
//   // Assert
//   expect(controller.userBookings.length, initialCount + 1);
//   });
//   }) {
//     // TODO: implement group
//     throw UnimplementedError();
//   }
// }
