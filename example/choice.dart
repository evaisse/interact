import 'dart:io' show stdout;

import 'package:interact/interact.dart';

Future<void> main() async {
  final beverages = ['Coffee', 'Tea', 'Soda', 'Water'];

  final preferred = Choice(
    prompt: 'Pick a beverage',
    options: beverages,
    useFuzzySearch: true,
  ).interact() as int;

  stdout.writeln('Enjoying ${beverages[preferred]}');

  final toppings = ['Cheese', 'Mushroom', 'Pepperoni', 'Spinach'];
  final selected = Choice(
    prompt: 'Pizza toppings',
    options: toppings,
    mode: ChoiceMode.multiple,
    defaults: const [true, false, true, false],
  ).interact() as List<int>;

  stdout.writeln(
    'Added: ${selected.map((i) => toppings[i]).join(', ')}',
  );
}
