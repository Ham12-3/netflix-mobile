import 'package:flutter_test/flutter_test.dart';
import 'package:luma_stream/config/app_config.dart';

void main() {
  test('app has an original brand name', () {
    expect(AppConfig.appName, 'Luma Stream');
  });
}
