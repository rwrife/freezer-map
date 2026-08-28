import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../tool/check_architecture.dart';

void main() {
  test('Freezer Map package imports respect layer boundaries', () {
    final violations = checkArchitecture(Directory.current);

    expect(violations, isEmpty, reason: violations.join('\n'));
  });
}
