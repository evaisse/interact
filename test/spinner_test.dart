import 'package:fake_async/fake_async.dart';
import 'package:interact/interact.dart';
import 'package:test/test.dart';

import 'helpers/fake_context.dart';

class TestSpinner extends Spinner with TestContextMixin<SpinnerState> {
  TestSpinner({
    required this.testContext,
    required super.icon,
    super.leftPrompt,
    super.rightPrompt,
  });

  @override
  final FakeContext testContext;
}

void main() {
  setUp(() {
    Theme.defaultTheme = Theme.basicTheme.copyWith(
      spinners: const ['-', '+'],
      spinningInterval: 10,
    );
  });

  test('spins until done is called', () {
    fakeAsync((async) {
      final context = FakeContext(windowWidth: 20);
      final spinner = TestSpinner(
        testContext: context,
        icon: '✓',
      );

      final state = spinner.interact();
      async.elapse(const Duration(milliseconds: 30));
      expect(context.renderCount, greaterThan(1));

      final disposer = state.done();
      disposer();

      final renderedBefore = context.renderCount;
      async.elapse(const Duration(milliseconds: 30));
      expect(context.renderCount, equals(renderedBefore));
    });
  });
}
