//user_tracking_screen
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserTrackingScreen extends StatefulWidget {
  const UserTrackingScreen({super.key});

  @override
  State<UserTrackingScreen> createState() => _UserTrackingScreenState();
}

class _UserTrackingScreenState extends State<UserTrackingScreen> {
  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionStream;
  Position? _currentPosition;
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


  Future<void> _initializeLocation() async {
    await _listenCurrentLocation();
  }

  bool _isPermissionGranted(LocationPermission permissionStatus) {
    return permissionStatus == LocationPermission.always || permissionStatus == LocationPermission.whileInUse;
  }

  Future<void> _handleLocationPermission(VoidCallback onSuccess) async {
    // access permission given or not
    LocationPermission permissionStatus = await Geolocator.checkPermission();
    if (_isPermissionGranted(permissionStatus)) {
      // GPS service enable
      bool isServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (isServiceEnabled) {
        onSuccess();
      } else {
        // -> Request service
        //await Geolocator.openAppSettings();
        await Geolocator.openLocationSettings();
      }
    } else {
      // -> Request location permission
      LocationPermission permissionStatus = await Geolocator.requestPermission();
      if (_isPermissionGranted(permissionStatus)) {
        // Call this method again
        await _listenCurrentLocation();
      }
    }
  }

  Future<void> _listenCurrentLocation() async {
    await _handleLocationPermission(() {
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0, // Distance in meters to trigger an update (0 means any movement)
      );
      _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings,).listen((position) {
        _currentPosition = position;
        _currentLatLng = LatLng(position.latitude, position.longitude);
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
      });
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
          points: List.from(_polyPoints),
          color: Colors.purple,
          width: 4,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          onTap: () {},
          consumeTapEvents: true,
        ),
      );
    }

    // Move camera
    _animateTo(_currentLatLng!);

    setState(() {});
  }

  /// ANIMATE MAP CAMERA
  void _animateTo(LatLng target) {
    _mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: target, zoom: 16)));
  }

  /// UPDATE MARKER POSITION + INFO WINDOW
  void _updateMarker(LatLng latLng) {
    _markers = {
      Marker(
        markerId: MarkerId("user_marker"),
        position: latLng,
        infoWindow: InfoWindow(title: "My Current Location", snippet: "Lat: ${latLng.latitude}, Lng: ${latLng.longitude}"),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Real-Time Location Tracker')),
      body: GoogleMap(
        mapType: MapType.normal,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
        zoomGesturesEnabled: true,
        trafficEnabled: true,
        onTap: (LatLng latLng) {
          print('Tapped on : $latLng');
        },
        onLongPress: (LatLng latLng) {
          print('Long pressed on : $latLng');
        },
        initialCameraPosition: CameraPosition(zoom: 16, target: LatLng(23.793658483514, 90.40683698304692)),
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        markers: _markers,
        polylines: _polylines,
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            FloatingActionButton(
              onPressed: () async {
                await _listenCurrentLocation();
                _mapController?.animateCamera(
                  CameraUpdate.newCameraPosition(CameraPosition(target: _currentLatLng ?? LatLng(23.719435420479336, 90.36848187446594), zoom: 16)),
                );
              },
              child: Icon(Icons.my_location),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _positionStream?.cancel();
    super.dispose();
  }
}
