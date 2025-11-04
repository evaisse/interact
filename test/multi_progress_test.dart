import 'package:interact/interact.dart';
import 'package:test/test.dart';

import 'helpers/fake_context.dart';

void main() {
  setUp(() {
    Theme.defaultTheme = Theme.basicTheme;
  });

  test('renders multiple progress bars and disposes cleanly', () {
    final context = FakeContext(windowWidth: 20);
    final multi = MultiProgress(context: context);

    final first = multi.add(
      Progress(length: 5, size: 0.5),
    );
    first.increase(3);

    final second = multi.add(
      Progress(length: 5, size: 0.5),
    );
    second.increase(2);

    expect(context.renderCount, greaterThanOrEqualTo(2));
    expect(context.writtenLines.length, equals(2));

    first.done();
    second.done();

    expect(context.writtenLines, isEmpty);
  });
}
