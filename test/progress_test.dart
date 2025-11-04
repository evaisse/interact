import 'package:interact/interact.dart';
import 'package:test/test.dart';

import 'helpers/fake_context.dart';

class TestProgress extends Progress with TestContextMixin<ProgressState> {
  TestProgress({
    required this.testContext,
    required super.length,
    super.size,
  });

  @override
  final FakeContext testContext;
}

void main() {
  setUp(() {
    Theme.defaultTheme = Theme.basicTheme;
  });

  test('increases, clears, and completes progress', () {
    final context = FakeContext(windowWidth: 20);
    final progress = TestProgress(
      testContext: context,
      length: 10,
      size: 0.5,
    );

    final state = progress.interact();

    state.increase(5);
    expect(context.renderCount, equals(2)); // initial + increase
    final afterIncrease =
        context.writtenLines.isEmpty ? '' : context.writtenLines.last;
    expect(afterIncrease.contains('#'), isTrue);

    state.clear();
    expect(context.renderCount, equals(3));
    final afterClear =
        context.writtenLines.isEmpty ? '' : context.writtenLines.last;
    expect(afterClear.contains('#'), isFalse);

    final rendersBefore = context.renderCount;
    final disposer = state.done();
    expect(disposer, isNotNull);
    expect(context.renderCount, equals(rendersBefore + 1));
  });
}
