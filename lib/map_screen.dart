import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  LatLng _currentPos = const LatLng(20.9374, 77.7796);

  @override
  void initState() {
    super.initState();
    _startTracking();
  }

  void _startTracking() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    // Modern stream setting to avoid 'undefined parameter' errors
    Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10)
    ).listen((Position position) {
      if (mounted) {
        setState(() {
          _currentPos = LatLng(position.latitude, position.longitude);
        });
        _mapController?.animateCamera(CameraUpdate.newLatLng(_currentPos));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Real-time Tracking")),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: _currentPos, zoom: 15),
        onMapCreated: (controller) => _mapController = controller,
        myLocationEnabled: true,
        markers: {
          Marker(markerId: const MarkerId("current"), position: _currentPos),
        },
      ),
    );
  }
}