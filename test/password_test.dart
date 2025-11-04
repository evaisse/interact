import 'package:interact/interact.dart';
import 'package:test/test.dart';

import 'helpers/fake_context.dart';

class TestPassword extends Password with TestContextMixin<String> {
  TestPassword({
    required this.testContext,
    required super.prompt,
    super.confirmation,
    super.confirmPrompt,
    super.confirmError,
  });

  @override
  final FakeContext testContext;
}

void main() {
  setUp(() {
    Theme.defaultTheme = Theme.basicTheme;
  });

  test('returns password without confirmation', () {
    final context = FakeContext(lines: ['s3cret']);
    final password = TestPassword(
      testContext: context,
      prompt: 'Password',
    );

    expect(password.interact(), equals('s3cret'));
  });

  test('retries until confirmation matches', () {
    final context = FakeContext(
      lines: [
        'initial',
        'mismatch',
        'initial',
        'initial',
      ],
    );
    final password = TestPassword(
      testContext: context,
      prompt: 'Password',
      confirmation: true,
      confirmError: 'Mismatch',
    );

    expect(password.interact(), equals('initial'));
  });
}
