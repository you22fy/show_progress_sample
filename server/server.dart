import 'dart:io';
import 'dart:convert';

Future<void> main() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
  print('サーバー起動: http://${server.address.host}:${server.port}');

  await for (HttpRequest request in server) {
    request.response.headers.add('Access-Control-Allow-Origin', 'http://localhost:60132');
    request.response.headers.add('Access-Control-Allow-Credentials', 'true');
    request.response.headers.add('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept');
    request.response.headers.add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');

    // OPTIONSメソッドの場合は早期に応答
    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.ok;
      await request.response.close();
      continue;
    }

    // 送信するチャンク数と各チャンクの遅延時間
    const int chunks = 1000;
    const duration = Duration(milliseconds: 10);

    // 各チャンクのバイト列を生成してリストに保持し、合計バイト数を計算
    List<List<int>> chunkBytesList = [];
    for (int i = 0; i < chunks; i++) {
      final dummyData = {
        'chunk': i + 1,
        'message': 'This is chunk ${i + 1}',
        'data': List.generate(20, (index) => 'Item ${index + 1} in chunk ${i + 1}'),
        'timestamp': DateTime.now().toIso8601String(),
      };

      final chunkStr = jsonEncode(dummyData) + "\n";
      final chunkBytes = utf8.encode(chunkStr);
      chunkBytesList.add(chunkBytes);
    }
    final totalBytes = chunkBytesList.fold(0, (sum, element) => sum + element.length);

    // Content-Length ヘッダーを設定してチャンク転送ではなく通常のレスポンスとして送信
    request.response.headers.contentLength = totalBytes;
    request.response.headers.contentType = ContentType.json;

    // 各チャンクを順次送信
    for (var chunkBytes in chunkBytesList) {
      request.response.add(chunkBytes);
      await request.response.flush();
      await Future.delayed(duration);
    }

    await request.response.close();
  }
}
