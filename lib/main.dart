import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MapTestScreen(),
    );
  }
}

class MapTestScreen extends StatefulWidget {
  const MapTestScreen({super.key});

  @override
  State<MapTestScreen> createState() => _MapTestScreenState();
}

class _MapTestScreenState extends State<MapTestScreen> {
  static const CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(35.6715, 139.6966),
    zoom: 14.0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('地図表示テスト')),
      body: const GoogleMap(
        initialCameraPosition: _kInitialPosition,
        mapType: MapType.normal, // 通常の地図形式
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
      ),
    );
  }
}