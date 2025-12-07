import 'package:flutter/material.dart';
import 'package:google_maps_location_tracker/gps_home_screen.dart';
import 'package:google_maps_location_tracker/home_screen.dart';
import 'package:google_maps_location_tracker/location_tracking_screen.dart';
import 'package:google_maps_location_tracker/user_location_screen.dart';
import 'package:google_maps_location_tracker/user_tracking_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(LocationTrackerApp());
}

class LocationTrackerApp extends StatelessWidget {
  const LocationTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: UserTrackingScreen(),
      ),
    );
  }
}