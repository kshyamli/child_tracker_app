import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // FIXED IMPORT
import 'package:cloud_firestore/cloud_firestore.dart';

class MapScreen extends StatefulWidget {
  final String childUID;
  const MapScreen({super.key, required this.childUID});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Live Tracking")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(widget.childUID).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          var data = snapshot.data!.data() as Map<String, dynamic>;
          double lat = data['last_lat'] ?? 20.5937;
          double lng = data['last_lng'] ?? 78.9629;
          LatLng position = LatLng(lat, lng); // THIS NOW WORKS

          return GoogleMap(
            initialCameraPosition: CameraPosition(target: position, zoom: 15),
            onMapCreated: (controller) => _controller = controller,
            markers: {
              Marker(markerId: const MarkerId("child"), position: position),
            },
          );
        },
      ),
    );
  }
}