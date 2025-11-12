import 'package:dart_console/dart_console.dart';

const _ansiReset = '\x1b[0m';
const _ansiBold = '\x1b[1m';
const _ansiUnderline = '\x1b[4m';

String _wrapWithAnsi(String value, String sequence) =>
    '$sequence$value$_ansiReset';

extension AnsiStringStyles on String {
  String yellow() =>
      _wrapWithAnsi(this, ConsoleColor.yellow.ansiSetForegroundColorSequence);

  String grey() => _wrapWithAnsi(
      this, ConsoleColor.brightBlack.ansiSetForegroundColorSequence);

  String green() =>
      _wrapWithAnsi(this, ConsoleColor.green.ansiSetForegroundColorSequence);

  String red() =>
      _wrapWithAnsi(this, ConsoleColor.red.ansiSetForegroundColorSequence);

  String cyan() =>
      _wrapWithAnsi(this, ConsoleColor.cyan.ansiSetForegroundColorSequence);

  String magenta() =>
      _wrapWithAnsi(this, ConsoleColor.magenta.ansiSetForegroundColorSequence);

  String blue() =>
      _wrapWithAnsi(this, ConsoleColor.blue.ansiSetForegroundColorSequence);

  String bold() => _wrapWithAnsi(this, _ansiBold);

  String underline() => _wrapWithAnsi(this, _ansiUnderline);

  String strip() => stripEscapeCharacters();
}
