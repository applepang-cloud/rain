import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import 'asset_server.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const RainApp());
}

class RainApp extends StatelessWidget {
  const RainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '비 오는 거리',
      home: RainScreen(),
    );
  }
}

class RainScreen extends StatefulWidget {
  const RainScreen({super.key});

  @override
  State<RainScreen> createState() => _RainScreenState();
}

class _RainScreenState extends State<RainScreen> {
  final AssetServer _assets = AssetServer();
  WebViewController? _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await _assets.start();

    final params = const PlatformWebViewControllerCreationParams();
    final controller = WebViewController.fromPlatformCreationParams(params);
    await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await controller.setBackgroundColor(const Color(0xFF1A1F24));

    // 미디어(WebAudio) 자동재생 허용 — 씬 내부의 '화면을 눌러 시작'으로 제스처를 받음.
    if (controller.platform is AndroidWebViewController) {
      final android = controller.platform as AndroidWebViewController;
      await android.setMediaPlaybackRequiresUserGesture(false);
    }

    await controller.loadRequest(Uri.parse(_assets.baseUrl));

    if (!mounted) return;
    setState(() {
      _controller = controller;
      _ready = true;
    });
  }

  @override
  void dispose() {
    _assets.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1F24),
      body: _ready && _controller != null
          ? WebViewWidget(controller: _controller!)
          : const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Color(0xFF8A97A3)),
              ),
            ),
    );
  }
}
