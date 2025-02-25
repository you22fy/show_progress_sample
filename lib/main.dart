import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Web CORS Demo',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Dio dio = Dio();
  double progress = 0.0;
  String progressText = "0%";
  String responseData = "";
  bool loading = false;

  Future<void> callApi() async {
    setState(() {
      loading = true;
      responseData = "";
      progress = 0.0;
      progressText = "0%";
    });

    // Flutter Web の場合、withCredentials を有効にする
    if (kIsWeb) {
      (dio.httpClientAdapter as dynamic).withCredentials = true;
    }

    try {
      final response = await dio.get(
        "http://127.0.0.1:8080", // サーバーのURL（CORS設定済み）
        options: Options(responseType: ResponseType.plain),
        onReceiveProgress: (int received, int total) {
          // ログ出力で受信バイトと総バイト数を確認
          print("received: $received, total: $total");
          if (total > 0) {
            double currentProgress = received / total;
            setState(() {
              progress = currentProgress;
              progressText = "${(currentProgress * 100).toStringAsFixed(0)}%";
            });
          } else {
            // total が不明な場合は「読み込み中…」と表示
            setState(() {
              progressText = "読み込み中...";
            });
          }
        },
      );
      setState(() {
        responseData = response.data;
      });
    } catch (e) {
      setState(() {
        responseData = "Error: $e";
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter Web CORS Demo"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // API呼び出しボタン
            ElevatedButton(
              onPressed: loading ? null : callApi,
              child: const Text("API呼び出し"),
            ),
            const SizedBox(height: 20),
            // 進捗バー（progress が Infinity にならないようにチェック）
            LinearProgressIndicator(
              value: progress.isFinite ? progress : 0.0,
              minHeight: 10,
            ),
            const SizedBox(height: 20),
            // 進捗テキスト
            Text(
              "進捗: $progressText",
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            // APIレスポンス表示エリア
            Expanded(
              child: SingleChildScrollView(
                child: Text(responseData),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
