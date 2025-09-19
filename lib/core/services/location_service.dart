class RealTimeTrackingService {
  static StreamSubscription<Position>? _positionSubscription;
  static StreamController<TrackingUpdate> _trackingController =
      StreamController.broadcast();

  static Stream<TrackingUpdate> get trackingStream =>
      _trackingController.stream;

  static void startTracking(String bookingId) {
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Update every 5 meters
        timeLimit: Duration(minutes: 1),
      ),
    ).listen((position) {
      // Update database
      FirebaseFirestore.instance
          .collection('live_tracking')
          .doc(bookingId)
          .set({
            'workerId': AuthController.to.currentUser.value!.id,
            'latitude': position.latitude,
            'longitude': position.longitude,
            'timestamp': FieldValue.serverTimestamp(),
            'speed': position.speed,
            'heading': position.heading,
          });

      // Emit to stream
      _trackingController.add(
        TrackingUpdate(
          workerId: AuthController.to.currentUser.value!.id,
          position: position,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  static void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }
}
