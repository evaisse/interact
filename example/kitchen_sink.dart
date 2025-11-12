import 'dart:io' show stdin, stdout;

import 'package:interact/interact.dart';

class _DemoEntry {
  const _DemoEntry({
    required this.emoji,
    required this.title,
    required this.summary,
    required this.run,
  });

  final String emoji;
  final String title;
  final String summary;
  final Future<void> Function() run;
}

final List<_DemoEntry> _demos = [
  const _DemoEntry(
    emoji: '👍',
    title: 'Confirm',
    summary: 'Binary question with default value',
    run: _runConfirmDemo,
  ),
  const _DemoEntry(
    emoji: '⌨️',
    title: 'Input',
    summary: 'Free-form text input with validation',
    run: _runInputDemo,
  ),
  const _DemoEntry(
    emoji: '🔐',
    title: 'Password',
    summary: 'Masked input with confirmation flow',
    run: _runPasswordDemo,
  ),
  const _DemoEntry(
    emoji: '🎯',
    title: 'Select',
    summary: 'Single-choice selector with cursor navigation',
    run: _runSelectDemo,
  ),
  const _DemoEntry(
    emoji: '🧩',
    title: 'MultiSelect',
    summary: 'Toggle multiple options with the space bar',
    run: _runMultiSelectDemo,
  ),
  const _DemoEntry(
    emoji: '🧠',
    title: 'FuzzySelect',
    summary: 'Single-choice selector with fuzzy search',
    run: _runFuzzySelectDemo,
  ),
  const _DemoEntry(
    emoji: '🔍',
    title: 'FuzzyMultiSelect',
    summary: 'Large list with fuzzy search and paging',
    run: _runFuzzyMultiSelectDemo,
  ),
  const _DemoEntry(
    emoji: '🧱',
    title: 'Sort',
    summary: 'Reorder items by dragging with arrow keys',
    run: _runSortDemo,
  ),
  const _DemoEntry(
    emoji: '🌪️',
    title: 'Spinner',
    summary: 'Single task spinner using ASCII frames',
    run: _runSpinnerDemo,
  ),
  const _DemoEntry(
    emoji: '🎡',
    title: 'MultiSpinner',
    summary: 'Track multiple concurrent spinners',
    run: _runMultiSpinnerDemo,
  ),
  const _DemoEntry(
    emoji: '📊',
    title: 'Progress',
    summary: 'Incremental bar updates with prompts',
    run: _runProgressDemo,
  ),
  const _DemoEntry(
    emoji: '🛠️',
    title: 'MultiProgress',
    summary: 'Side-by-side progress bars',
    run: _runMultiProgressDemo,
  ),
  const _DemoEntry(
    emoji: '🔀',
    title: 'Choice',
    summary: 'Unified single or multi selector with optional fuzzy search',
    run: _runChoiceDemo,
  ),
];

Future<void> main() async {
  stdout
    ..writeln('Interact Kitchen Sink')
    ..writeln('Explore the available components from a single menu.\n');

  while (true) {
    final menuTheme = Theme.defaultTheme.copyWith(
      activeItemStyle: (text) => text,
      inactiveItemStyle: (text) => text,
    );

    final choice = Select.withTheme(
      theme: menuTheme,
      prompt: 'Pick a demo to run',
      options: [
        for (final demo in _demos)
          '${demo.emoji} ${_formatComponentName(demo.title)} — ${demo.summary}',
        '🚪 Exit',
      ],
    ).interact();

    if (choice == _demos.length) {
      stdout.writeln('\nSee you next time!');
      break;
    }

    final demo = _demos[choice];

    stdout
      ..writeln('\n=== ${demo.emoji} ${_formatComponentName(demo.title)} ===')
      ..writeln('${demo.summary}\n');
    await demo.run();

    _pause();
  }
}

Future<void> _runConfirmDemo() {
  final answer = Confirm(
    prompt: 'Do you enjoy command-line interfaces?',
    defaultValue: true,
  ).interact();

  stdout.writeln(
    answer
        ? 'Awesome! Keep building cool CLIs.'
        : 'No worries, we will improve.',
  );

  return Future<void>.value();
}

Future<void> _runInputDemo() {
  final name = Input(
    prompt: 'What should we call you?',
    validator: (value) {
      if (value.trim().isEmpty) {
        throw ValidationError('Please enter at least one character');
      }
      return true;
    },
  ).interact();

  stdout.writeln('Hello, $name!');
  return Future<void>.value();
}

Future<void> _runPasswordDemo() {
  final secret = Password(
    prompt: 'Create a short passphrase',
    confirmation: true,
    confirmPrompt: 'Confirm passphrase',
  ).interact();

  stdout.writeln('Stored a passphrase with ${secret.length} characters.');
  return Future<void>.value();
}

Future<void> _runSelectDemo() {
  final languages = ['Rust', 'Dart', 'TypeScript', 'Go', 'Python'];

  final choice = Select(
    prompt: 'Pick a language for your next CLI',
    options: languages,
    initialIndex: 1,
  ).interact();

  stdout.writeln('Great choice: ${languages[choice]}');
  return Future<void>.value();
}

Future<void> _runMultiSelectDemo() {
  final toppings = [
    'Cheese',
    'Mushroom',
    'Pepperoni',
    'Pineapple',
    'Spinach',
  ];

  final indices = MultiSelect(
    prompt: 'Build your pizza',
    options: toppings,
    defaults: [true, false, true, false, false],
  ).interact()
    ..sort();

  if (indices.isEmpty) {
    stdout.writeln('Plain crust it is!');
  } else {
    final picked = indices.map((i) => toppings[i]).join(', ');
    stdout.writeln('Toppings on deck: $picked');
  }

  return Future<void>.value();
}

Future<void> _runFuzzySelectDemo() {
  final commands = [
    'analyze',
    'build',
    'clean',
    'deploy',
    'doc',
    'format',
    'test',
  ];

  final index = FuzzySelect(
    prompt: 'Pick a CLI command',
    options: commands,
    pageSize: 4,
  ).interact();

  stdout.writeln('Executing `${commands[index]}`');
  return Future<void>.value();
}

Future<void> _runFuzzyMultiSelectDemo() {
  final packages = [
    'ansi-escapes',
    'chalk',
    'clipanion',
    'commander',
    'enquirer',
    'figures',
    'flutter',
    'inquirer',
    'interact',
    'mason',
    'oclif',
    'prompt_toolkit',
    'sentry-cli',
    'solidarity',
    'spectre',
    'spin',
    'turbo',
    'wireit',
    'yargs',
  ];

  final indices = FuzzyMultiSelect(
    prompt: 'Select CLI helpers you often reach for',
    options: packages,
    pageSize: 6,
  ).interact()
    ..sort();

  if (indices.isEmpty) {
    stdout.writeln('No helpers selected.');
  } else {
    final result = indices.map((i) => packages[i]).join(', ');
    stdout.writeln('Keeping these handy: $result');
  }

  return Future<void>.value();
}

Future<void> _runSortDemo() {
  final backlog = [
    'Setup CI',
    'Ship onboarding welcome',
    'Polish spinner copy',
    'Write changelog',
  ];

  final ordered = Sort(
    prompt: 'Rank upcoming tasks (top = most urgent)',
    options: backlog,
  ).interact();

  stdout.writeln('Updated priority order: ${ordered.join(' → ')}');
  return Future<void>.value();
}

Future<void> _runChoiceDemo() {
  final fruits = ['Apple', 'Banana', 'Cherry', 'Dragonfruit'];

  final singleResult = Choice(
    prompt: 'Select a favourite fruit',
    options: fruits,
    useFuzzySearch: true,
  ).interact();

  if (singleResult is! int) {
    throw StateError('Expected a single index from Choice in single mode.');
  }
  final single = singleResult;

  stdout.writeln('Favourite fruit: ${fruits[single]}');

  final toppings = ['Cheese', 'Mushroom', 'Pepperoni', 'Spinach'];
  final multiResult = Choice(
    prompt: 'Pizza toppings',
    options: toppings,
    mode: ChoiceMode.multiple,
    defaults: const [true, false, true, false],
  ).interact();

  if (multiResult is! List<int>) {
    throw StateError(
        'Expected a list of indices from Choice in multiple mode.');
  }
  final multi = List<int>.from(multiResult)..sort();

  final picked = multi.map((i) => toppings[i]).join(', ');
  stdout.writeln('Toppings chosen: $picked');

  return Future<void>.value();
}

Future<void> _runSpinnerDemo() async {
  final spinner = Spinner(
    icon: '✅',
    rightPrompt: (done) => done ? 'task finished' : 'scheduling work',
  ).interact();

  await Future.delayed(const Duration(seconds: 2));

  spinner.done();
  stdout.writeln('Spinner completed.');
}

Future<void> _runMultiSpinnerDemo() async {
  final deck = MultiSpinner();

  final download = deck.add(
    Spinner(
      icon: '⬇️',
      rightPrompt: (done) => done ? 'downloaded' : 'fetching artifact',
    ),
  );
  final verify = deck.add(
    Spinner(
      icon: '🔍',
      rightPrompt: (done) => done ? 'verified' : 'running checks',
    ),
  );
  final publish = deck.add(
    Spinner(
      icon: '🚀',
      rightPrompt: (done) => done ? 'published' : 'shipping release',
    ),
  );

  await Future.delayed(const Duration(milliseconds: 900));
  download.done();
  await Future.delayed(const Duration(milliseconds: 900));
  verify.done();
  await Future.delayed(const Duration(milliseconds: 900));
  publish.done();

  stdout.writeln('All spinners signed off.');
}

Future<void> _runProgressDemo() async {
  const length = 80;

  final progress = Progress(
    length: length,
    rightPrompt: (current) =>
        ' ${(current / length * 100).round().toString().padLeft(3)}%',
  ).interact();

  for (var i = 0; i < length; i++) {
    await Future.delayed(const Duration(milliseconds: 40));
    progress.increase(1);
  }

  progress.done();
  stdout.writeln('Download finished.');
}

Future<void> _runMultiProgressDemo() async {
  final group = MultiProgress();
  const length = 60;

  var lintProgress = 0;
  var testProgress = 0;
  var packageProgress = 0;

  final lint = group.add(
    Progress(
      length: length,
      rightPrompt: (current) => ' lint ${(current / length * 100).round()}%',
    ),
  );
  final test = group.add(
    Progress(
      length: length,
      rightPrompt: (current) => ' test ${(current / length * 100).round()}%',
    ),
  );
  final package = group.add(
    Progress(
      length: length,
      rightPrompt: (current) => ' package ${(current / length * 100).round()}%',
    ),
  );

  for (var i = 0; i < length; i++) {
    await Future.delayed(const Duration(milliseconds: 35));
    lint.increase(1);
    lintProgress++;
    if (i.isEven) {
      test.increase(1);
      testProgress++;
    }
    if (i % 3 == 0) {
      package.increase(1);
      packageProgress++;
    }
  }

  await Future.delayed(const Duration(milliseconds: 400));

  while (lintProgress < length) {
    await Future.delayed(const Duration(milliseconds: 20));
    lint.increase(1);
    lintProgress++;
  }
  while (testProgress < length) {
    await Future.delayed(const Duration(milliseconds: 20));
    test.increase(1);
    testProgress++;
  }
  while (packageProgress < length) {
    await Future.delayed(const Duration(milliseconds: 20));
    package.increase(1);
    packageProgress++;
  }

  lint.done();
  test.done();
  package.done();
  stdout.writeln('Pipeline wrapped up.');
}

void _pause() {
  stdout
    ..writeln('\nPress Enter to return to the menu.')
    ..write('> ');
  stdin.readLineSync();
  stdout.writeln();
}

String _formatComponentName(String name) => name.magenta().bold();
