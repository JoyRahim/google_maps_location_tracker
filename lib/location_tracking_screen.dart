//location_tracking_screen
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';


class LocationTrackingScreen extends StatefulWidget {
  const LocationTrackingScreen({super.key});

  @override
  State<LocationTrackingScreen> createState() => _LocationTrackingScreenState();
}

class _LocationTrackingScreenState extends State<LocationTrackingScreen> {
  GoogleMapController? _controller;

  LatLng? _currentLatLng;
  LatLng? _previousLatLng;

  Set<Polyline> _polylines = {};
  List<LatLng> _polyPoints = [];

  Set<Marker> _markers = {};

  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  /// INITIAL LOCATION + START TIMER
  Future<void> _initializeLocation() async {
    await _checkPermissions();

    Position pos = await Geolocator.getCurrentPosition();
    _currentLatLng = LatLng(pos.latitude, pos.longitude);

    _updateMarker(_currentLatLng!);

    setState(() {});

    // Smooth map animation
    Future.delayed(Duration(milliseconds: 500), () {
      _animateTo(_currentLatLng!);
    });

    // Start periodic location updates
    _locationTimer = Timer.periodic(Duration(seconds: 10), (_) {
      _updateLocation();
    });
  }

  /// FETCH NEW LOCATION EVERY 10s
  Future<void> _updateLocation() async {
    Position pos = await Geolocator.getCurrentPosition();

    _previousLatLng = _currentLatLng;
    _currentLatLng = LatLng(pos.latitude, pos.longitude);

    // Update marker
    _updateMarker(_currentLatLng!);

    // Add polyline point
    if (_previousLatLng != null) {
      _polyPoints.add(_previousLatLng!);
      _polyPoints.add(_currentLatLng!);

      _polylines.add(
        Polyline(
          polylineId: PolylineId(DateTime.now().toString()),
          width: 5,
          points: List.from(_polyPoints),
          color: Colors.blue,
        ),
      );
    }

    // Move camera
    _animateTo(_currentLatLng!);

    setState(() {});
  }

  /// ANIMATE MAP CAMERA
  void _animateTo(LatLng target) {
    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: target,
          zoom: 17,
        ),
      ),
    );
  }

  /// UPDATE MARKER POSITION + INFO WINDOW
  void _updateMarker(LatLng latLng) {
    _markers = {
      Marker(
        markerId: MarkerId("user_marker"),
        position: latLng,
        infoWindow: InfoWindow(
          title: "My Current Location",
          snippet: "Lat: ${latLng.latitude}, Lng: ${latLng.longitude}",
        ),
      ),
    };
  }

  /// LOCATION PERMISSION
  Future<void> _checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Real-Time Location Tracker"),
      ),
      body: _currentLatLng == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
        onMapCreated: (controller) => _controller = controller,
        initialCameraPosition: CameraPosition(
          target: _currentLatLng!,
          zoom: 16,
        ),
        markers: _markers,
        polylines: _polylines,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
