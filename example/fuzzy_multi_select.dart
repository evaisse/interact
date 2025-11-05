import 'dart:io' show stdout;

import 'package:interact/interact.dart';

void main() {
  final libraries = [
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

  final choices = FuzzyMultiSelect(
    prompt: 'Select the tools you use regularly',
    options: libraries,
    pageSize: 8,
  ).interact();

  if (choices.isEmpty) {
    stdout.writeln('Nothing selected.');
    return;
  }

  final picked = choices.map((index) => libraries[index]).join(', ');
  stdout.writeln('You selected: $picked');
}
