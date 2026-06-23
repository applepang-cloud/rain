import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // 참고: TestWidgetsFlutterBinding이 HttpClient를 가로채 400을 돌려주므로
  // 루프백 AssetServer는 통합 테스트로 검증할 수 없다. 대신 WebView가 로드할
  // 번들 에셋들이 실제로 패키징되어 있고 내용이 올바른지 rootBundle로 확인한다.

  test('three.js 씬(index.html)이 번들되고 핵심 마크업을 포함한다', () async {
    final html = await rootBundle.loadString('assets/game/index.html');
    expect(html.contains('비 오는 거리'), isTrue);
    expect(html.contains('three.min.js'), isTrue); // 로컬 번들 참조
    expect(html.contains('rain.png'), isTrue); // 배경 이미지
    expect(html.contains('__RAIN'), isTrue); // 디버그 훅
  });

  test('three.min.js 번들이 존재하고 비어있지 않다', () async {
    final js = await rootBundle.load('assets/game/three.min.js');
    expect(js.lengthInBytes, greaterThan(100000));
  });

  test('배경 이미지 rain.png가 번들된다', () async {
    final png = await rootBundle.load('assets/game/rain.png');
    expect(png.lengthInBytes, greaterThan(1000));
    // PNG 시그니처
    final bytes = png.buffer.asUint8List();
    expect(bytes[0], 0x89);
    expect(bytes[1], 0x50); // 'P'
  });
}
