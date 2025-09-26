import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';

class NearbyWorkersRepository {
  final _db = FirebaseFirestore.instance;
  final _geo = GeoFlutterFire();

  Stream<List<Map<String, dynamic>>> watchNearby(double lat, double lng, double radiusKm, {String? category}) {
    final center = _geo.point(latitude: lat, longitude: lng);
    final ref = _db.collection('worker_locations');
    final stream = _geo.collection(collectionRef: ref).within(
          center: center,
          radius: radiusKm,
          field: 'position',
          strictMode: true,
        );
    return stream.asyncMap((docs) async {
      final ids = docs.map((d) => d['uid'] as String).toList();
      if (ids.isEmpty) return <Map<String, dynamic>>[];
      final workersSnap = await _db.collection('workers').where('uid', whereIn: ids).get();
      final workers = workersSnap.docs
          .map((d) => d.data())
          .where((w) => (category == null) || w['category'] == category)
          .toList();
      return workers;
    });
  }
}
