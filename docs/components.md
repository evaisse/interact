# Component Usage Guide

This guide highlights the interactive components exposed by `package:interact`
and shows the quickest way to make them part of a CLI experience. All
components are available from `package:interact/interact.dart`.

## Confirm

Use `Confirm` when you need a boolean answer:

```dart
final accepted = Confirm(
  prompt: 'Proceed with deployment?',
  defaultValue: true,
  waitForNewLine: true,
).interact();
```

- `defaultValue` pre-fills the answer if the user simply presses <kbd>Enter</kbd>.
- `waitForNewLine` forces confirmation before returning.

## Input

Collect free-form text with optional validation logic:

```dart
final username = Input(
  prompt: 'GitHub username',
  initialText: 'octocat',
  validator: (value) {
    if (value.trim().isEmpty) {
      throw ValidationError('A username is required');
    }
    return true;
  },
).interact();
```

The `validator` throws a `ValidationError` to show inline feedback.

## Password

`Password` hides terminal input by default and can ask for confirmation:

```dart
final secret = Password(
  prompt: 'Access token',
  confirmation: true,
  confirmPrompt: 'Repeat access token',
  confirmError: 'Tokens do not match',
).interact();
```

Passwords are never echoed back; the success prompt renders a placeholder.

## Select

Single-choice menus return the index of the selected option:

```dart
final environments = ['Production', 'Staging', 'QA'];
final selected = Select(
  prompt: 'Target environment',
  options: environments,
  initialIndex: 1,
).interact();

print('Deploying to ${environments[selected]}');
```

Arrow keys move the highlight; <kbd>Enter</kbd> accepts the choice.

## MultiSelect

Capture zero or more choices with checkboxes:

```dart
final features = ['Billing', 'Analytics', 'Dashboard'];
final enabled = MultiSelect(
  prompt: 'Enable modules',
  options: features,
  defaults: const [true, false, true],
).interact();

print('Enabled: ${enabled.map((i) => features[i]).join(', ')}');
```

Press <kbd>Space</kbd> to toggle the current option, <kbd>Enter</kbd> to finish.

## FuzzyMultiSelect

Add fuzzy filtering and pagination to multi-select workflows:

```dart
final packages = [
  'analyzer',
  'build_runner',
  'fake_async',
  'lints',
  'test',
];
final chosen = FuzzyMultiSelect(
  prompt: 'Select dependencies',
  options: packages,
  pageSize: 3,
  searchPlaceholder: 'Type to filter packages',
).interact();
```

- Start typing to filter results with fuzzy matching.
- Use <kbd>Ctrl</kbd>+<kbd>A</kbd> to select everything in view.
- Navigate with arrows, <kbd>PgUp</kbd>/<kbd>PgDn</kbd>, or jump with
  <kbd>Home</kbd>/<kbd>End</kbd>.

## FuzzySelect

Add fuzzy search to a single-choice selector:

```dart
final packages = ['args', 'async', 'build_runner', 'test'];
final index = FuzzySelect(
  prompt: 'Pick a package 🔍',
  options: packages,
  pageSize: 3,
).interact();

print('Using ${packages[index]}');
```

## Sort

Reorder items interactively and return the sorted list:

```dart
final tasks = ['Docs', 'Implementation', 'Review'];
final ordered = Sort(
  prompt: 'Prioritise tasks',
  options: tasks,
  showOutput: true,
).interact();
```

Toggle an item with <kbd>Space</kbd>, then move it using arrow keys. The final
ordering is returned as a new list.

## Spinner

Render a single animated spinner until you mark it as done:

```dart
final spinner = Spinner(
  icon: '✅',
  rightPrompt: (done) => done ? 'Done' : 'Working…',
).interact();

await Future<void>.delayed(const Duration(milliseconds: 500));
spinner.done();
```

`done()` returns a disposer to clear the spinner immediately when invoked.

## MultiSpinner

Coordinate multiple spinners with a shared renderer:

```dart
final spinners = MultiSpinner();
final build = spinners.add(Spinner(icon: '🔧'));
final deploy = spinners.add(Spinner(icon: '🚀'));

await Future<void>.delayed(const Duration(milliseconds: 300));
build.done();

await Future<void>.delayed(const Duration(milliseconds: 300));
deploy.done();
```

`MultiSpinner` batches output to avoid clobbering the terminal when several
spinners update concurrently.

## Progress

Display and update a single progress bar:

```dart
final progress = Progress(
  length: 100,
  leftPrompt: (current) => 'Building ',
  rightPrompt: (current) => ' ${current}% ',
).interact();

for (var i = 0; i < 10; i++) {
  await Future<void>.delayed(const Duration(milliseconds: 50));
  progress.increase(10);
}

progress.done();
```

Call `increase` to advance the bar, `clear` to reset, and `done` to remove it.

## MultiProgress

Manage multiple progress bars together:

```dart
final multi = MultiProgress();
final first = multi.add(Progress(length: 5));
final second = multi.add(Progress(length: 5));

first.increase(5);
second.increase(3);

first.done();
second.done();
```

`MultiProgress` mirrors `MultiSpinner`, sharing a rendering context so several
bars can update without flickering.
## Choice

Combine single or multi selection with optional fuzzy search through one
component:

```dart
final fruits = ['Apple', 'Banana', 'Cherry'];
final rawResult = Choice(
  prompt: 'Pick fruit',
  options: fruits,
  mode: ChoiceMode.multiple,
  useFuzzySearch: true,
).interact();

if (rawResult is! List<int>) {
  throw StateError('Expected a list of indices from Choice in multiple mode.');
}

print('Selected: ${rawResult.map((i) => fruits[i]).join(', ')}');
```
