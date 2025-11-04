import 'package:interact/interact.dart';
import 'package:test/test.dart';

import 'helpers/fake_context.dart';

class TestInput extends Input with TestContextMixin<String> {
  TestInput({
    required this.testContext,
    required super.prompt,
    super.validator,
    super.initialText,
    super.defaultValue,
  });

  @override
  final FakeContext testContext;
}

void main() {
  setUp(() {
    Theme.defaultTheme = Theme.basicTheme;
  });

  test('returns user input', () {
    final context = FakeContext(lines: ['alice']);
    final input = TestInput(
      testContext: context,
      prompt: 'Name',
    );

    expect(input.interact(), equals('alice'));
  });

  test('falls back to default when input is empty', () {
    final context = FakeContext(lines: ['']);
    final input = TestInput(
      testContext: context,
      prompt: 'Name',
      defaultValue: 'bob',
    );

    expect(input.interact(), equals('bob'));
  });

  test('re-prompts until validator succeeds', () {
    final context = FakeContext(lines: ['invalid', 'okay']);
    final input = TestInput(
      testContext: context,
      prompt: 'Value',
      validator: (value) {
        if (value == 'okay') {
          return true;
        }
        throw ValidationError('bad value');
      },
    );

    expect(input.interact(), equals('okay'));
  });
}
