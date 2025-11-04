import 'package:dart_console/dart_console.dart';
import 'package:interact/interact.dart';
import 'package:test/test.dart';

import 'helpers/fake_context.dart';

class TestConfirm extends Confirm with TestContextMixin<bool> {
  TestConfirm({
    required this.testContext,
    required super.prompt,
    super.defaultValue,
    super.waitForNewLine,
  });

  @override
  final FakeContext testContext;
}

void main() {
  setUp(() {
    Theme.defaultTheme = Theme.basicTheme;
  });

  test('returns true when user confirms', () {
    final context = FakeContext(
      keys: [Key.printable('y')],
    );
    final confirm = TestConfirm(
      testContext: context,
      prompt: 'Continue?',
    );

    expect(confirm.interact(), isTrue);
  });

  test('waitForNewLine requires enter before returning', () {
    final context = FakeContext(
      keys: [
        Key.printable('n'),
        Key.control(ControlCharacter.enter),
      ],
    );
    final confirm = TestConfirm(
      testContext: context,
      prompt: 'Continue?',
      waitForNewLine: true,
    );

    expect(confirm.interact(), isFalse);
  });

  test('default value is used when enter is pressed immediately', () {
    final context = FakeContext(
      keys: [Key.control(ControlCharacter.enter)],
    );
    final confirm = TestConfirm(
      testContext: context,
      prompt: 'Continue?',
      defaultValue: true,
    );

    expect(confirm.interact(), isTrue);
  });
}
