import 'package:dart_console/dart_console.dart';
import 'package:interact/interact.dart';
import 'package:test/test.dart';

import 'helpers/fake_context.dart';

class TestFuzzySelect extends FuzzySelect with TestContextMixin<int> {
  TestFuzzySelect({
    required this.testContext,
    required super.prompt,
    required super.options,
    super.initialIndex,
    super.pageSize,
    super.searchPlaceholder,
  });

  @override
  final FakeContext testContext;
}

void main() {
  test('returns initial index when enter is pressed immediately', () {
    final context = FakeContext(
      keys: [Key.control(ControlCharacter.enter)],
    );
    final select = TestFuzzySelect(
      testContext: context,
      prompt: 'Command',
      options: const ['build', 'test'],
      initialIndex: 1,
    );

    expect(select.interact(), equals(1));
  });

  test('filters by search query and confirms selection', () {
    final context = FakeContext(
      keys: [
        Key.printable('t'),
        Key.control(ControlCharacter.enter),
      ],
    );
    final select = TestFuzzySelect(
      testContext: context,
      prompt: 'Command',
      options: const ['build', 'deploy', 'test'],
    );

    expect(select.interact(), equals(2));
  });
}
