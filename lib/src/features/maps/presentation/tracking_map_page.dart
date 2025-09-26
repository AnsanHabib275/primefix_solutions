import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackingMapPage extends StatefulWidget {
  const TrackingMapPage({super.key});
  @override
  State<TrackingMapPage> createState() => _TrackingMapPageState();
}

class _TrackingMapPageState extends State<TrackingMapPage> {
  final workerIdCtrl = TextEditingController(text: 'WORKER_UID_HERE');
  StreamSubscription<DocumentSnapshot>? sub;
  GoogleMapController? map;
  Marker? workerMarker;
  LatLng initial = const LatLng(24.8607, 67.0011); // Karachi

  @override
  void dispose() {
    sub?.cancel();
    super.dispose();
  }

  void _startTracking() {
    sub?.cancel();
    final id = workerIdCtrl.text.trim();
    if (id.isEmpty) return;
    sub = FirebaseFirestore.instance.collection('worker_locations').doc(id).snapshots().listen((doc) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) return;
      final gp = data['position']?['geopoint'];
      if (gp == null) return;
      final lat = gp.latitude as double;
      final lng = gp.longitude as double;
      final pos = LatLng(lat, lng);
      setState(() {
        workerMarker = Marker(markerId: const MarkerId('worker'), position: pos, infoWindow: const InfoWindow(title: 'Worker'));
      });
      map?.animateCamera(CameraUpdate.newLatLng(pos));
    });
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>{if (workerMarker != null) workerMarker!};
    return Scaffold(
      appBar: AppBar(title: const Text('Live Tracking')),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(children: [
            Expanded(child: TextField(controller: workerIdCtrl, decoration: const InputDecoration(labelText: 'Worker UID'))),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: _startTracking, child: const Text('Track')),
          ]),
        ),
        Expanded(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(target: initial, zoom: 12),
            onMapCreated: (c) => map = c,
            markers: markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
        ),
      ]),
    );
  }
}
