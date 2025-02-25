import 'dart:io';
import 'dart:convert';

Future<void> main() async {
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
  print('サーバー起動: http://${server.address.host}:${server.port}');
  const clientLocalHost = 'http://localhost:3000';

  await for (HttpRequest request in server) {
    request.response.headers
        .add('Access-Control-Allow-Origin', clientLocalHost);
    request.response.headers.add('Access-Control-Allow-Credentials', 'true');
    request.response.headers.add('Access-Control-Allow-Headers',
        'Origin, X-Requested-With, Content-Type, Accept');
    request.response.headers
        .add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.ok;
      await request.response.close();
      continue;
    }

    // 1000個のチャンクを10msごとに
    const int chunks = 1000;
    const duration = Duration(milliseconds: 10);

    List<List<int>> chunkBytesList = [];
    for (int i = 0; i < chunks; i++) {
      final dummyData = {
        'chunk': i + 1,
        'message': 'This is chunk ${i + 1}',
        'data':
            List.generate(20, (index) => 'Item ${index + 1} in chunk ${i + 1}'),
        'timestamp': DateTime.now().toIso8601String(),
      };

      final chunkStr = "${jsonEncode(dummyData)}\n";
      final chunkBytes = utf8.encode(chunkStr);
      chunkBytesList.add(chunkBytes);
    }
    final totalBytes =
        chunkBytesList.fold(0, (sum, element) => sum + element.length);

    request.response.headers.contentLength = totalBytes;
    request.response.headers.contentType = ContentType.json;

    for (var chunkBytes in chunkBytesList) {
      request.response.add(chunkBytes);
      await request.response.flush();
      await Future.delayed(duration);
    }

    await request.response.close();
  }
}
