import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:primefix_solutions/controllers/auth_controller.dart';

class LocationController extends GetxController {
  final Rx<Position?> currentPosition = Rx<Position?>(null);
  final RxList<Worker> nearbyWorkers = <Worker>[].obs;
  final RxBool isTracking = false.obs;

  StreamSubscription<Position>? positionStream;

  @override
  void onInit() {
    super.onInit();
    requestLocationPermission();
  }

  Future<void> getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      currentPosition.value = position;
      await findNearbyWorkers();
    } catch (e) {
      Get.snackbar('Location Error', 'Failed to get current location');
    }
  }

  Future<void> findNearbyWorkers({double radiusKm = 10.0}) async {
    if (currentPosition.value == null) return;

    final workers = await WorkerService.getNearbyWorkers(
      lat: currentPosition.value!.latitude,
      lng: currentPosition.value!.longitude,
      radius: radiusKm,
    );

    nearbyWorkers.value = workers;
  }

  // Real-time tracking for active bookings
  void startTracking() {
    if (isTracking.value) return;

    isTracking.value = true;
    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen((position) {
      currentPosition.value = position;

      // Update worker location in real-time
      if (AuthController.to.currentUser.value?.role == 'worker') {
        WorkerService.updateLocation(position);
      }
    });
  }

  void stopTracking() {
    positionStream?.cancel();
    isTracking.value = false;
  }
}
