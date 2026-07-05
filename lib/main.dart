import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'model/dog_run_map_model.dart';
import 'service/dog_run_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'dogrun表示テスト',
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
  late Future<List<DogRunMapData>> _dogRunsFuture;

  // 地図の初期表示位置（代々木公園付近）
  static const CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(35.6715, 139.6966),
    zoom: 12.5,
  );

  @override
  void initState() {
    super.initState();
    _dogRunsFuture = _apiService.fetchMapRuns();
  }

  // APIから取得したドッグランのリストを、GoogleMap用のMarker（ピン）のセットに変換する関数
  Set<Marker> _convertToMarkers(List<DogRunMapData> dogRuns) {
    return dogRuns.map((run) {
      return Marker(
        markerId: MarkerId(run.id.toString()),
        position: LatLng(run.latitude, run.longitude),
        infoWindow: InfoWindow(
          title: run.name,
          snippet: '現在の滞在数: ${run.activeDogCount}匹',
        ),
      );
    }).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('dogRun 表示テスト'),
        backgroundColor: Colors.amber,
      ),
      body: FutureBuilder<List<DogRunMapData>>(
        future: _dogRunsFuture,
        builder: (context, snapshot) {
          // 1. 読み込み中（Spring Bootからのレスポンス待ち）の画面
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // 2. エラー発生時の画面
          else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'データ取得エラーが発生しました:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          // 3. データが空、またはうまく取得できなかった時の画面
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('表示できるドッグラン情報がありません。'),
            );
          }

          // 4. 【成功】データが正常に届いた場合の画面
          final List<DogRunMapData> dogRuns = snapshot.data!;
          final Set<Marker> mapMarkers = _convertToMarkers(dogRuns);

          return GoogleMap(
            initialCameraPosition: _kInitialPosition,
            mapType: MapType.normal,
            markers: mapMarkers,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
          );
        },
      ),
    );
  }
}