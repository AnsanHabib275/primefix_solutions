import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';

class WorkerLocationService {
  final _db = FirebaseFirestore.instance;
  final _geo = GeoFlutterFire();
  Timer? _timer;

  Future<void> start(String workerId) async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
      return;
    }
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) async {
      final pos = await Geolocator.getCurrentPosition();
      final point = _geo.point(latitude: pos.latitude, longitude: pos.longitude);
      await _db.collection('worker_locations').doc(workerId).set({
        'uid': workerId,
        'position': point.data,
        'updatedAt': FieldValue.serverTimestamp(),
        'online': true,
      }, SetOptions(merge: true));
    });
  }

  void stop() {
    _timer?.cancel();
  }
}
