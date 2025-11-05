import 'dart:io' show stdout;

import 'package:interact/interact.dart';

Future<void> main() async {
  final shells = [
    'bash',
    'elvish',
    'fish',
    'nushell',
    'powershell',
    'xonsh',
    'zsh',
  ];

  final index = FuzzySelect(
    prompt: 'Preferred shell',
    options: shells,
    pageSize: 4,
  ).interact();

  stdout.writeln('Launching ${shells[index]}…');
}
