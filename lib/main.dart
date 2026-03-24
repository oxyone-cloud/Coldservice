import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: OxyOneMap()));
}

class OxyOneMap extends StatelessWidget {
  const OxyOneMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("OxyONE - Logistique Oran"),
        backgroundColor: Colors.blueGrey[900],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('monitoring').snapshots(),
        builder: (context, snapshot) {
          List<Marker> markers = [];
          List<LatLng> points = [];

          if (snapshot.hasData) {
            for (var doc in snapshot.data!.docs) {
              var d = doc.data() as Map<String, dynamic>;
              if (d.containsKey('lat') && d.containsKey('lng')) {
                var p = LatLng(d['lat'] as double, d['lng'] as double);
                points.add(p);
                markers.add(
                  Marker(
                    point: p,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                  ),
                );
              }
            }
          }

          return FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(35.69, -0.63), // Oran
              initialZoom: 8,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.oxyone.app',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: points,
                    strokeWidth: 4,
                    color: Colors.blue,
                  ),
                ],
              ),
              MarkerLayer(markers: markers),
            ],
          );
        },
      ),
    );
  }
}
