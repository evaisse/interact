import 'package:dart_console/dart_console.dart';
import 'package:interact/interact.dart';
import 'package:test/test.dart';

import 'helpers/fake_context.dart';

class TestMultiSelect extends MultiSelect with TestContextMixin<List<int>> {
  TestMultiSelect({
    required this.testContext,
    required super.prompt,
    required super.options,
    super.defaults,
  });

  @override
  final FakeContext testContext;
}

void main() {
  setUp(() {
    Theme.defaultTheme = Theme.basicTheme;
  });

  final options = ['a', 'b', 'c'];

  test('respects default selections', () {
    final context = FakeContext(
      keys: [Key.control(ControlCharacter.enter)],
    );
    final multi = TestMultiSelect(
      testContext: context,
      prompt: 'Pick some',
      options: options,
      defaults: const [true, false, true],
    );

    expect(multi.interact(), equals([0, 2]));
  });

  test('toggles selections with space and confirms with enter', () {
    final context = FakeContext(
      keys: [
        Key.printable(' '),
        Key.control(ControlCharacter.arrowDown),
        Key.printable(' '),
        Key.control(ControlCharacter.enter),
      ],
    );
    final multi = TestMultiSelect(
      testContext: context,
      prompt: 'Pick some',
      options: options,
    );

    expect(multi.interact(), equals([0, 1]));
  });
}
