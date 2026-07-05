import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ApiTestScreen(),
    );
  }
}

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  String _responseMessage = 'ボタンを押してSpring Bootと通信を開始';
  bool _isLoading = false;

  // Dioの初期化（AndroidエミュレータからPCのローカルへ接続するIP）
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2:8080/api',
    connectTimeout: const Duration(seconds: 5),
  ));

  // APIを叩く関数
  Future<void> _connectToSpringBoot() async {
    setState(() {
      _isLoading = true;
      _responseMessage = '通信中...';
    });

    try {
      final response = await _dio.get('/dogRuns');

      setState(() {
        _isLoading = false;
        _responseMessage = '【通信成功！】\n\n${response.data.toString()}';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _responseMessage = '【通信失敗】\n\nエラー詳細: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('フェーズ2: API疎通テスト')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isLoading) const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    _responseMessage,
                    style: const TextStyle(fontSize: 16, fontFamily: 'monospace'),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _connectToSpringBoot,
                child: const Text('Spring Bootからデータ取得'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}