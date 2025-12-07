/*
//user_location_screen
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class UserLocationScreen extends StatefulWidget {
  const UserLocationScreen({super.key});

  @override
  State<UserLocationScreen> createState() => _UserLocationScreenState();
}

class _UserLocationScreenState extends State<UserLocationScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(23.777176, 90.399452), // Dhaka, Bangladesh
    zoom: 16.0,
  );

  // Map elements
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  final List<LatLng> _polylineCoordinates = [];

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    // Request permission using permission_handler
    var status = await Permission.location.request();

    if (status.isGranted) {
      _startLocationUpdates();
    } else if (status.isDenied) {
      // Show a message or dialog if permission is denied
      await Geolocator.openLocationSettings();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Location permission denied. Cannot track location.')));
      }
    }
  }

  void _startLocationUpdates() {
    // Define the desired location settings
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0, // Distance in meters to trigger an update (0 means any movement)
    );

    // Get continuous updates (Geolocator will manage the 10-second check)
    _positionStreamSubscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
      setState(() {
        _currentPosition = position;

        final newLatLng = LatLng(position.latitude, position.longitude);

        // 1. Automatic Map Animation
        if (_mapController != null) {
          _mapController!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: newLatLng, zoom: 16.0)));
        }

        // 3. Polyline Tracking & 2. Update Marker
        _updateMapElements(newLatLng);
      });
    });
  }

  // --- Task 3 & 4: Map Elements Update ---

  void _updateMapElements(LatLng newLatLng) {
    // 3. Polyline Tracking
    if (_polylineCoordinates.isEmpty || _polylineCoordinates.last != newLatLng) {
      _polylineCoordinates.add(newLatLng);
    }

    _polylines.clear();
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('tracking_path'),
        points: _polylineCoordinates,
        color: Colors.blue,
        width: 4,
        geodesic: true,
      ),
    );

    // 2. Update Marker & 4. Marker Information Window
    _markers.clear();
    final marker = Marker(
      markerId: const MarkerId('current_location'),
      position: newLatLng,
      infoWindow: InfoWindow(
        title: 'My current location',
        snippet: 'Lat: ${newLatLng.latitude.toStringAsFixed(6)}, Lon: ${newLatLng.longitude.toStringAsFixed(6)}',
      ),
    );
    _markers.add(marker);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Real-Time Location Tracker'), backgroundColor: Colors.blueAccent),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initialCameraPosition,
            markers: _markers,
            polylines: _polylines,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              // If location is already available, animate to it on map creation
              if (_currentPosition != null) {
                final latLng = LatLng(_currentPosition!.latitude, _currentPosition!.longitude);
                _mapController!.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: latLng, zoom: 16.0)));
              }
            },
          ),
          // Display current coordinates overlay
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [BoxShadow(blurRadius: 5, color: Colors.black26)],
              ),
              child: _currentPosition == null
                  ? const Text('Fetching Location...', style: TextStyle(fontWeight: FontWeight.bold))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('My Current Location (Real-Time)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 5),
                        Text('Latitude: ${_currentPosition!.latitude.toStringAsFixed(6)}'),
                        Text('Longitude: ${_currentPosition!.longitude.toStringAsFixed(6)}'),
                      ],
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Manually recenter the map to the current location
          if (_currentPosition != null && _mapController != null) {
            _mapController!.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(target: LatLng(_currentPosition!.latitude, _currentPosition!.longitude), zoom: 16.0),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location not yet available.')));
          }
        },
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
*/
