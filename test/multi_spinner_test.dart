import 'package:fake_async/fake_async.dart';
import 'package:interact/interact.dart';
import 'package:test/test.dart';

import 'helpers/fake_context.dart';

void main() {
  setUp(() {
    Theme.defaultTheme = Theme.basicTheme.copyWith(
      spinners: const ['-', '+'],
      spinningInterval: 10,
    );
  });

  test('manages multiple spinners with shared context', () {
    fakeAsync((async) {
      final context = FakeContext(windowWidth: 20);
      final multi = MultiSpinner(context: context);

      final first = multi.add(Spinner(icon: 'A'));
      final second = multi.add(Spinner(icon: 'B'));

      async.elapse(const Duration(milliseconds: 40));
      expect(context.renderCount, greaterThan(0));
      expect(context.writtenLines.length, equals(2));

      first.done();
      second.done();

      final renders = context.renderCount;
      async.elapse(const Duration(milliseconds: 40));
      expect(context.renderCount, equals(renders));
    });
  });
}
