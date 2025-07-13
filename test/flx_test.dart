import 'package:flx_cli/flx.dart';
import 'package:test/test.dart';

void main() {
  group('FLX CLI Tests', () {
    test('should create FlxCli instance', () {
      final cli = FlxCli();
      expect(cli, isNotNull);
    });

    test('should have correct version', () {
      expect(FlxCli.version, equals('1.0.0'));
    });
  });
}
