import 'package:dopa/core/app_environment.dart';
import 'package:flutter/services.dart' show appFlavor;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps Flutter app flavor to the Dopa environment', () {
    expect(AppEnvironment.name, appFlavor ?? 'dev');

    if (appFlavor == 'prod') {
      expect(AppEnvironment.current, DopaEnvironment.prod);
      expect(AppEnvironment.isProduction, isTrue);
      expect(AppEnvironment.displayName, 'Dopa');
    } else {
      expect(AppEnvironment.current, DopaEnvironment.dev);
      expect(AppEnvironment.isProduction, isFalse);
      expect(AppEnvironment.displayName, 'Dopa Dev');
    }
  });
}
