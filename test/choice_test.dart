import 'package:interact/interact.dart';
import 'package:test/test.dart';

void main() {
  test('uses Select for single choice without fuzzy search', () {
    final choice = Choice(
      prompt: 'Pick',
      options: const ['A', 'B'],
    );

    expect(choice.delegate, isA<Select>());
  });

  test('uses FuzzySelect when fuzzy search enabled', () {
    final choice = Choice(
      prompt: 'Pick',
      options: const ['alpha', 'beta'],
      useFuzzySearch: true,
    );

    expect(choice.delegate, isA<FuzzySelect>());
  });

  test('uses MultiSelect for multi choice without fuzzy search', () {
    final choice = Choice(
      prompt: 'Pick',
      options: const ['A', 'B'],
      mode: ChoiceMode.multiple,
    );

    expect(choice.delegate, isA<MultiSelect>());
  });

  test('uses FuzzyMultiSelect when multi and fuzzy', () {
    final choice = Choice(
      prompt: 'Pick',
      options: const ['alpha', 'beta'],
      mode: ChoiceMode.multiple,
      useFuzzySearch: true,
    );

    expect(choice.delegate, isA<FuzzyMultiSelect>());
  });
}
