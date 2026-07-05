import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      // 1. スマホの位置情報サービスが有効かチェック
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      // 2. アプリの位置情報権限をチェック
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

      // 3. タイムアウトを設定して安全に現在地を取得（5秒以内に取れなければnullを返す）
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 5));
    } catch (e) {
      // エミュレータのバグ等で例外が発生しても、アプリを落とさずnullを返す
      print("位置情報取得でエラー（スキップします）: $e");
      return null;
    }
  }
}