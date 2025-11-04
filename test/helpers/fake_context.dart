import 'dart:collection';

import 'package:dart_console/dart_console.dart';
import 'package:interact/src/framework/framework.dart';

/// A lightweight console implementation for driving components in tests.
class FakeContext extends Context {
  FakeContext({
    Iterable<Key> keys = const [],
    Iterable<String> lines = const [],
    int windowWidth = 80,
  })  : _keys = Queue<Key>.of(keys),
        _lines = Queue<String>.of(lines),
        _windowWidth = windowWidth;

  final Queue<Key> _keys;
  final Queue<String> _lines;
  final int _windowWidth;

  final List<String> _written = [];
  final List<String> _writtenInline = [];

  /// Captures the most recent rendered lines.
  List<String> get writtenLines => List.unmodifiable(_written);

  /// Captures inline writes (without a line break).
  List<String> get inlineWrites => List.unmodifiable(_writtenInline);

  void pushKeys(Iterable<Key> keys) => _keys.addAll(keys);

  void pushLines(Iterable<String> lines) => _lines.addAll(lines);

  @override
  int get windowWidth => _windowWidth;

  @override
  void hideCursor() {}

  @override
  void showCursor() {}

  @override
  void write(String text) {
    _writtenInline.add(text);
  }

  @override
  void writeln([String? text]) {
    increaseLinesCount();
    _written.add(text ?? '');
  }

  @override
  void erasePreviousLine([int n = 1]) {
    for (var i = 0; i < n; i++) {
      if (_written.isNotEmpty) {
        _written.removeLast();
      }
    }
  }

  @override
  Key readKey() {
    if (_keys.isEmpty) {
      throw StateError('No more key events configured for FakeContext.');
    }
    return _keys.removeFirst();
  }

  @override
  String readLine({String initialText = '', bool noRender = false}) {
    if (_lines.isEmpty) {
      throw StateError('No more line inputs configured for FakeContext.');
    }
    final value = _lines.removeFirst();
    increaseLinesCount();
    _written.add('');
    return value;
  }
}

/// Injects a [FakeContext] into a component under test.
mixin TestContextMixin<T> on Component<T> {
  FakeContext get testContext;

  @override
  State pipeState(State state) {
    state.setContext(testContext);
    return state;
  }
}
