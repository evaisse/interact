import 'dart:io' show stdout;

void main() {
  stdout.writeAll(
    [
      'All the examples are available in their specific files in this directory!',
      'For example, run `dart example/select.dart` to see an example of a Select component.',
      'Or try `dart example/kitchen_sink.dart` to explore every component from one menu.',
      '',
      '- Frenco',
      '',
    ],
    '\n',
  );
}
