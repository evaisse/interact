import 'dart:math' show max, min;

import 'package:dart_console/dart_console.dart';
import 'package:interact/src/framework/framework.dart';
import 'package:interact/src/theme/theme.dart';
import 'package:interact/src/utils/ansi_styles.dart';
import 'package:interact/src/utils/fuzzy.dart';
import 'package:interact/src/utils/prompt.dart';

/// Presents a single-choice selector with optional fuzzy search.
///
/// ```dart
/// final stacks = ['Dart', 'Rust', 'Go', 'TypeScript'];
/// final index = FuzzySelect(
///   prompt: 'Pick a stack for your next CLI ⚙️',
///   options: stacks,
///   pageSize: 3,
/// ).interact();
///
/// print('Selected ${stacks[index]}');
/// ```
class FuzzySelect extends Component<int> {
  FuzzySelect({
    required this.prompt,
    required this.options,
    this.initialIndex = 0,
    this.pageSize = 10,
    this.searchPlaceholder = 'Type to filter',
  })  : assert(options.isNotEmpty, "Options can't be empty"),
        theme = Theme.defaultTheme;

  FuzzySelect.withTheme({
    required this.prompt,
    required this.options,
    required this.theme,
    this.initialIndex = 0,
    this.pageSize = 10,
    this.searchPlaceholder = 'Type to filter',
  }) : assert(options.isNotEmpty, "Options can't be empty");

  final Theme theme;
  final String prompt;
  final List<String> options;
  final int initialIndex;
  final int pageSize;
  final String searchPlaceholder;

  @override
  _FuzzySelectState createState() => _FuzzySelectState();
}

class _FuzzySelectState extends State<FuzzySelect> {
  late List<_Result> _results;
  var _query = '';
  var _highlight = 0;
  var _top = 0;

  @override
  void init() {
    super.init();
    _results = _buildResults('');
    _highlight = min(component.initialIndex, _results.length - 1);

    context.writeln(
      promptInput(
        theme: component.theme,
        message: component.prompt,
      ),
    );
    context.hideCursor();
  }

  @override
  void dispose() {
    context.writeln(
      promptSuccess(
        theme: component.theme,
        message: component.prompt,
        value: component.theme.valueStyle(_results[_highlight].label),
      ),
    );
    context.showCursor();

    super.dispose();
  }

  @override
  void render() {
    final header = StringBuffer('Search: ');
    if (_query.isEmpty) {
      header.write(component.theme.hintStyle(component.searchPlaceholder));
    } else {
      header.write(_query);
    }
    context.writeln(header.toString());

    final status = StringBuffer()
      ..write('${_results.length} match')
      ..write(_results.length == 1 ? '' : 'es');
    context.writeln(component.theme.hintStyle(status.toString()));

    context.writeln(
      component.theme.hintStyle(
        'Use Up/Down to move · Enter confirms · Type to filter',
      ),
    );

    if (_results.isEmpty) {
      context.writeln(component.theme.errorStyle('No matches'));
      return;
    }

    final end = min(_top + component.pageSize, _results.length);
    for (var i = _top; i < end; i++) {
      final result = _results[i];
      final isActive = i == _highlight;
      final buffer = StringBuffer();

      if (component.theme.showActiveCursor) {
        buffer.write(
          isActive
              ? component.theme.activeItemPrefix
              : component.theme.inactiveItemPrefix,
        );
        buffer.write(' ');
      }

      buffer.write(
        isActive
            ? component.theme.checkedItemPrefix
            : component.theme.uncheckedItemPrefix,
      );
      buffer.write(' ');
      buffer.write(_decorateLabel(result, isActive));

      context.writeln(buffer.toString());
    }

    if (end < _results.length) {
      context.writeln(
        component.theme.hintStyle('... ${_results.length - end} more'),
      );
    }
  }

  @override
  int interact() {
    while (true) {
      final key = context.readKey();

      if (key.isControl) {
        switch (key.controlChar) {
          case ControlCharacter.arrowUp:
            _moveHighlight(-1);
            break;
          case ControlCharacter.arrowDown:
            _moveHighlight(1);
            break;
          case ControlCharacter.pageUp:
            _moveHighlight(-component.pageSize);
            break;
          case ControlCharacter.pageDown:
            _moveHighlight(component.pageSize);
            break;
          case ControlCharacter.home:
            _jumpTo(0);
            break;
          case ControlCharacter.end:
            _jumpTo(_results.isEmpty ? 0 : _results.length - 1);
            break;
          case ControlCharacter.backspace:
          case ControlCharacter.ctrlH:
            if (_query.isNotEmpty) {
              _updateQuery(_query.substring(0, _query.length - 1));
            }
            break;
          case ControlCharacter.ctrlU:
            if (_query.isNotEmpty) {
              _updateQuery('');
            }
            break;
          case ControlCharacter.enter:
            return _results[_highlight].index;
          default:
            break;
        }
        continue;
      }

      if (key.char.isNotEmpty) {
        _updateQuery('$_query${key.char}');
      }
    }
  }

  void _moveHighlight(int delta) {
    if (_results.isEmpty) {
      return;
    }
    final length = _results.length;
    final target = (_highlight + delta) % length;
    final next = target < 0 ? target + length : target;

    setState(() {
      _highlight = next;
      if (_highlight < _top) {
        _top = _highlight;
      } else if (_highlight >= _top + component.pageSize) {
        _top = max(0, _highlight - component.pageSize + 1);
      }
    });
  }

  void _jumpTo(int index) {
    if (_results.isEmpty) {
      return;
    }
    var bounded = index;
    if (bounded < 0) {
      bounded = 0;
    } else if (bounded >= _results.length) {
      bounded = _results.length - 1;
    }

    setState(() {
      _highlight = bounded;
      _top = (bounded ~/ component.pageSize) * component.pageSize;
    });
  }

  void _updateQuery(String value) {
    final results = _buildResults(value);
    setState(() {
      _query = value;
      _results = results;

      if (_results.isEmpty) {
        _highlight = 0;
        _top = 0;
        return;
      }

      if (_highlight >= _results.length) {
        _highlight = 0;
      }
      _top = (_highlight ~/ component.pageSize) * component.pageSize;
    });
  }

  List<_Result> _buildResults(String rawQuery) {
    final query = rawQuery.trim();

    if (query.isEmpty) {
      return component.options.asMap().entries.map(
        (entry) {
          return _Result(
            index: entry.key,
            label: entry.value,
            score: 0,
            matches: const [],
          );
        },
      ).toList();
    }

    final results = <_Result>[];
    for (var i = 0; i < component.options.length; i++) {
      final label = component.options[i];
      final match = FuzzyMatcher.evaluate(query, label);
      if (match == null) {
        continue;
      }
      results.add(
        _Result(
          index: i,
          label: label,
          score: match.score,
          matches: match.positions,
        ),
      );
    }

    results.sort((a, b) {
      final diff = b.score.compareTo(a.score);
      if (diff != 0) {
        return diff;
      }
      return a.label.compareTo(b.label);
    });

    return results;
  }

  String _decorateLabel(_Result result, bool isActive) {
    final highlightSet = result.matches.toSet();
    final buffer = StringBuffer();

    final applyItemStyle = isActive
        ? component.theme.activeItemStyle
        : component.theme.inactiveItemStyle;

    for (var i = 0; i < result.label.length; i++) {
      final char = result.label[i];
      final styled = applyItemStyle(char);
      buffer.write(
        highlightSet.contains(i) ? styled.bold() : styled,
      );
    }

    return buffer.isEmpty ? applyItemStyle(result.label) : buffer.toString();
  }
}

class _Result {
  const _Result({
    required this.index,
    required this.label,
    required this.score,
    required this.matches,
  });

  final int index;
  final String label;
  final double score;
  final List<int> matches;
}
