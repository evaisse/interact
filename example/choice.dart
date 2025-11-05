import 'dart:io' show stdout;

import 'package:interact/interact.dart';

Future<void> main() async {
  final beverages = ['Coffee', 'Tea', 'Soda', 'Water'];

  final preferredResult = Choice(
    prompt: 'Pick a beverage',
    options: beverages,
    useFuzzySearch: true,
  ).interact();

  if (preferredResult is! int) {
    throw StateError('Expected a single index from Choice in single mode.');
  }
  final preferred = preferredResult;

  stdout.writeln('Enjoying ${beverages[preferred]}');

  final toppings = ['Cheese', 'Mushroom', 'Pepperoni', 'Spinach'];
  final selectedResult = Choice(
    prompt: 'Pizza toppings',
    options: toppings,
    mode: ChoiceMode.multiple,
    defaults: const [true, false, true, false],
  ).interact();

  if (selectedResult is! List<int>) {
    throw StateError(
        'Expected a list of indices from Choice in multiple mode.');
  }
  final selected = selectedResult;

  stdout.writeln(
    'Added: ${selected.map((i) => toppings[i]).join(', ')}',
  );
}
