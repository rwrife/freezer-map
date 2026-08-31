import 'package:flutter_test/flutter_test.dart';
import 'package:freezer_map/domain/contracts.dart';

void main() {
  test('injected clocks and ID sources are deterministic contracts', () {
    final instant = DateTime.utc(2026, 8, 31, 12, 34);
    final clock = _Clock(instant);
    final ids = _Ids(['first', 'second']);

    expect(clock.nowUtc(), instant);
    expect(ids.next(), 'first');
    expect(ids.next(), 'second');
  });
}

final class _Clock implements Clock {
  const _Clock(this.value);

  final DateTime value;

  @override
  DateTime nowUtc() => value;
}

final class _Ids implements StableIdSource {
  _Ids(this.values);

  final List<String> values;

  @override
  String next() => values.removeAt(0);
}
