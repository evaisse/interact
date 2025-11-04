import 'package:dart_console/dart_console.dart';
import 'package:interact/interact.dart';
import 'package:test/test.dart';

import 'helpers/fake_context.dart';

class TestSort extends Sort with TestContextMixin<List<String>> {
  TestSort({
    required this.testContext,
    required super.prompt,
    required super.options,
    super.showOutput,
  });

  @override
  final FakeContext testContext;
}

void main() {
  setUp(() {
    Theme.defaultTheme = Theme.basicTheme;
  });

  final options = ['a', 'b', 'c'];

  test('returns items in their initial order when no moves are made', () {
    final context = FakeContext(
      keys: [Key.control(ControlCharacter.enter)],
    );
    final sort = TestSort(
      testContext: context,
      prompt: 'Sort',
      options: options,
    );

    expect(sort.interact(), equals(options));
  });

  test('moves a picked item with arrow keys', () {
    final context = FakeContext(
      keys: [
        Key.printable(' '),
        Key.control(ControlCharacter.arrowDown),
        Key.control(ControlCharacter.arrowDown),
        Key.control(ControlCharacter.enter),
      ],
    );
    final sort = TestSort(
      testContext: context,
      prompt: 'Sort',
      options: options,
    );

    expect(sort.interact(), equals(['b', 'c', 'a']));
  });
}
