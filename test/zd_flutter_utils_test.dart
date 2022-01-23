import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zd_flutter_utils/zd_flutter_utils.dart';

void main() {
  const MethodChannel channel = MethodChannel('zd_flutter_utils');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await ZdFlutterUtils.platformVersion, '42');
  });
}
