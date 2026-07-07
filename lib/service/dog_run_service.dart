import 'package:dio/dio.dart';
import '../model/dog_run_map_model.dart';
import 'dart:io';

class DogRunService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: Platform.isAndroid ? 'http://10.0.2.2:8080/api' : 'http://localhost:8080/api',
  ));

  Future<List<DogRunMapData>> fetchMapRuns() async {
    final response = await _dio.get('/dogRuns');
    if (response.statusCode == 200) {
      List<dynamic> data = response.data;
      return data.map((json) => DogRunMapData.fromJson(json)).toList();
    }
    throw Exception('Failed to load data');
  }

  Future<DogRunMapData> checkIn(int id) async {
    try {
      print('/dogRuns/$id/checkIn');
      final response = await _dio.post('/dogRuns/$id/checkIn');

      if (response.statusCode == 200) {
        return DogRunMapData.fromJson(response.data);
      }
      throw Exception('チェックインに失敗しました');
    } catch (e) {
      throw Exception('通信エラー: $e');
    }
  }
}