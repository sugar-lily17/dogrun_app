import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'model/dog_run_map_model.dart';
import 'service/dog_run_service.dart';
import 'service/location_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'ドッグランマップ',
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final DogRunService _apiService = DogRunService();
  final LocationService _locationService = LocationService();

  late Future<MapDataResult> _mapDataFuture;
  static const LatLng _defaultCenter = LatLng(35.6715, 139.6966);

  // リアルタイムにピンの状態を更新するため、取得したドッグランデータをStateでも保持する
  List<DogRunMapData> _dogRuns = [];

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _mapDataFuture = _loadInitialData();
    });
  }

  Future<MapDataResult> _loadInitialData() async {
    final results = await Future.wait([
      _locationService.getCurrentLocation(),
      _apiService.fetchMapRuns(),
    ]);

    _dogRuns = results[1] as List<DogRunMapData>;

    return MapDataResult(
      currentPosition: results[0] as Position?,
      dogRuns: _dogRuns,
    );
  }

  Future<void> _handleCheckIn(int id) async {
    try {
      final updatedRun = await _apiService.checkIn(id);

      setState(() {
        final index = _dogRuns.indexWhere((run) => run.id == id);
        if (index != -1) {
          _dogRuns[index] = updatedRun;
        }
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${updatedRun.name} にチェックインしました！')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('エラー: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showDetailBottomSheet(DogRunMapData run) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // コンテンツの大きさに合わせる
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(run.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text('現在のワンちゃん: ${run.activeDogCount} 匹', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _handleCheckIn(run.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.directions_run),
                  label: const Text('チェックイン', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Set<Marker> _convertToMarkers(List<DogRunMapData> dogRuns) {
    return dogRuns.map((run) {
      return Marker(
        markerId: MarkerId(run.id.toString()),
        position: LatLng(run.latitude, run.longitude),
        // 💡 標準のInfoWindow（吹き出し）は無効化し、タップ時にボトムシートを開く
        onTap: () => _showDetailBottomSheet(run),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('チェックイン'),
        backgroundColor: Colors.amber,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData, // 手動リフレッシュボタン
          )
        ],
      ),
      body: FutureBuilder<MapDataResult>(
        future: _mapDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('エラー: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('データなし'));
          }

          final data = snapshot.data!;
          final LatLng mapCenter = data.currentPosition != null
              ? LatLng(data.currentPosition!.latitude, data.currentPosition!.longitude)
              : _defaultCenter;

          return GoogleMap(
            initialCameraPosition: CameraPosition(target: mapCenter, zoom: 13.5),
            mapType: MapType.normal,
            markers: _convertToMarkers(_dogRuns), // Stateのリストからマーカーを生成
            myLocationEnabled: data.currentPosition != null,
            myLocationButtonEnabled: data.currentPosition != null,
          );
        },
      ),
    );
  }
}

class MapDataResult {
  final Position? currentPosition;
  final List<DogRunMapData> dogRuns;
  MapDataResult({required this.currentPosition, required this.dogRuns});
}