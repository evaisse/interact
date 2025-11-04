import 'package:dart_console/dart_console.dart';
import 'package:interact/interact.dart';
import 'package:test/test.dart';

import 'helpers/fake_context.dart';

class TestFuzzyMultiSelect extends FuzzyMultiSelect
    with TestContextMixin<List<int>> {
  TestFuzzyMultiSelect({
    required this.testContext,
    required super.prompt,
    required super.options,
    super.defaults,
    super.pageSize,
  });

  @override
  final FakeContext testContext;
}

void main() {
  setUp(() {
    Theme.defaultTheme = Theme.basicTheme;
  });

  final options = ['alpha', 'beta', 'gamma'];

  test('selects everything with ctrl+a', () {
    final context = FakeContext(
      keys: [
        Key.control(ControlCharacter.ctrlA),
        Key.control(ControlCharacter.enter),
      ],
    );
    final select = TestFuzzyMultiSelect(
      testContext: context,
      prompt: 'Select',
      options: options,
    );

    expect(select.interact(), equals([0, 1, 2]));
  });

  test('filters options as the user types', () {
    final context = FakeContext(
      keys: [
        Key.printable('b'),
        Key.printable(' '),
        Key.control(ControlCharacter.enter),
      ],
    );
    final select = TestFuzzyMultiSelect(
      testContext: context,
      prompt: 'Select',
      options: options,
    );

    expect(select.interact(), equals([1]));
  });
}
