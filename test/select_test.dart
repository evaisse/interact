import 'package:dart_console/dart_console.dart';
import 'package:interact/interact.dart';
import 'package:test/test.dart';

import 'helpers/fake_context.dart';

class TestSelect extends Select with TestContextMixin<int> {
  TestSelect({
    required this.testContext,
    required super.prompt,
    required super.options,
    super.initialIndex,
  });

  @override
  final FakeContext testContext;
}

void main() {
  setUp(() {
    Theme.defaultTheme = Theme.basicTheme;
  });

  final options = ['a', 'b', 'c'];

  test('returns initial index when enter is pressed immediately', () {
    final context = FakeContext(
      keys: [Key.control(ControlCharacter.enter)],
    );
    final select = TestSelect(
      testContext: context,
      prompt: 'Pick one',
      options: options,
    );

    expect(select.interact(), equals(0));
  });

  test('navigates with arrow keys', () {
    final context = FakeContext(
      keys: [
        Key.control(ControlCharacter.arrowDown),
        Key.control(ControlCharacter.arrowDown),
        Key.control(ControlCharacter.enter),
      ],
    );
    final select = TestSelect(
      testContext: context,
      prompt: 'Pick one',
      options: options,
    );

    expect(select.interact(), equals(2));
  });

  test('wraps around when moving above the first item', () {
    final context = FakeContext(
      keys: [
        Key.control(ControlCharacter.arrowUp),
        Key.control(ControlCharacter.enter),
      ],
    );
    final select = TestSelect(
      testContext: context,
      prompt: 'Pick one',
      options: options,
    );

    expect(select.interact(), equals(2));
  });
}
