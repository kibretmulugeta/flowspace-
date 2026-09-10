import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CounterNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void increment() => state++;
}

final counterProvider = NotifierProvider<CounterNotifier, int>(CounterNotifier.new);

void main() {
  test('Notifier works in Riverpod 3.x', () {
    final container = ProviderContainer();
    expect(container.read(counterProvider), 0);
    container.read(counterProvider.notifier).increment();
    expect(container.read(counterProvider), 1);
  });
}
