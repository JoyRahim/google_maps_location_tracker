import 'package:flutter/material.dart';
import 'package:google_maps_location_tracker/gps_home_screen.dart';
import 'package:google_maps_location_tracker/home_screen.dart';

void main() {
  runApp(LocationTracerApp());
}

class LocationTracerApp extends StatelessWidget {
  const LocationTracerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      //home: HomeScreen(),
      home: GpsHomeScreen(),
    );
  }
}