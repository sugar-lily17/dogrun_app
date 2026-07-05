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
  final LocationService _locationService = LocationService();

  // 画面に必要な2つのデータをまとめたFuture
  late Future<MapDataResult> _mapDataFuture;

  // 地図の初期表示位置（代々木公園付近）
  static const LatLng _defaultCenter = LatLng(35.6715, 139.6966);

  @override
  void initState() {
    super.initState();
    _mapDataFuture = _loadInitialData();
  }

  // 現在地とドッグラン一覧を並列で取得する非同期関数
  Future<MapDataResult> _loadInitialData() async {
    // Future.waitで並列処理（JavaのCompletableFuture.allOfのようなもの）
    final results = await Future.wait([
      _locationService.getCurrentLocation(),
      _apiService.fetchMapRuns(),
    ]);

    return MapDataResult(
      currentPosition: results[0] as Position?,
      dogRuns: results[1] as List<DogRunMapData>,
    );
  }

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
      body: FutureBuilder<MapDataResult>(
        future: _mapDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('データ取得エラー: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text('データを読み込めませんでした。'));
          }

          final data = snapshot.data!;
          final Set<Marker> mapMarkers = _convertToMarkers(data.dogRuns);

          // 現在地が取得できていればそれをターゲットに、無ければデフォルト（東京）にする
          final LatLng mapCenter = data.currentPosition != null
              ? LatLng(data.currentPosition!.latitude, data.currentPosition!.longitude)
              : _defaultCenter;

          return GoogleMap(
            initialCameraPosition: CameraPosition(
              target: mapCenter,
              zoom: 13.5,
            ),
            mapType: MapType.normal,
            markers: mapMarkers,
            // 現在地が取得できている場合のみ、マップ上の青い丸と現在地ボタンを有効化
            myLocationEnabled: data.currentPosition != null,
            myLocationButtonEnabled: data.currentPosition != null,
          );
        },
      ),
    );
  }
}

// 複数の非同期結果を1つにまとめるコンテナクラス
class MapDataResult {
  final Position? currentPosition; // 取得失敗を許容するためNullableにする
  final List<DogRunMapData> dogRuns;
  MapDataResult({required this.currentPosition, required this.dogRuns});
}