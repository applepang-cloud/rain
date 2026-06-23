import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

/// 번들된 three.js 씬(assets/game/*)을 localhost HTTP로 서빙하는 내장 서버.
/// WebView가 file:// 대신 http://127.0.0.1:port 로 로드하도록 해
/// 상대경로 리소스(three.min.js, rain.png)와 WebAudio가 안정적으로 동작하게 한다.
class AssetServer {
  HttpServer? _server;
  int get port => _server?.port ?? 0;
  String get baseUrl => 'http://127.0.0.1:$port';

  static const _root = 'assets/game';

  static const _types = <String, String>{
    'html': 'text/html; charset=utf-8',
    'js': 'application/javascript; charset=utf-8',
    'png': 'image/png',
    'jpg': 'image/jpeg',
    'css': 'text/css; charset=utf-8',
  };

  Future<void> start() async {
    // 임의 포트(0)로 루프백 바인딩
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server!.listen(_handle);
  }

  Future<void> _handle(HttpRequest req) async {
    var path = req.uri.path;
    if (path == '/' || path.isEmpty) path = '/index.html';
    final assetPath = '$_root$path';
    final ext = path.contains('.') ? path.split('.').last.toLowerCase() : '';
    try {
      final data = await rootBundle.load(assetPath);
      req.response.headers.contentType = null;
      req.response.headers.set('Content-Type', _types[ext] ?? 'application/octet-stream');
      req.response.headers.set('Cache-Control', 'no-cache');
      req.response.add(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    } catch (_) {
      req.response.statusCode = HttpStatus.notFound;
      req.response.write('Not found: $assetPath');
    }
    await req.response.close();
  }

  Future<void> dispose() async {
    await _server?.close(force: true);
    _server = null;
  }
}
