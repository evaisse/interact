import 'dart:math' show max, min;

import 'package:dart_console/dart_console.dart';
import 'package:interact/src/framework/framework.dart';
import 'package:interact/src/theme/theme.dart';
import 'package:interact/src/utils/ansi_styles.dart';
import 'package:interact/src/utils/fuzzy.dart';
import 'package:interact/src/utils/prompt.dart';

/// Like [MultiSelect], but adds fuzzy search, paging, and keyboard shortcuts.
///
/// ```dart
/// final crates = [
///   'ansi_term',
///   'clap',
///   'duct',
///   'inquire',
///   'indicatif',
///   'yew',
/// ];
///
/// final chosen = FuzzyMultiSelect(
///   prompt: 'Favorite CLI crates 🔎',
///   options: crates,
///   pageSize: 4,
/// ).interact();
/// ```
class FuzzyMultiSelect extends Component<List<int>> {
  FuzzyMultiSelect({
    required this.prompt,
    required this.options,
    this.defaults,
    this.pageSize = 10,
    this.searchPlaceholder = 'Type to filter',
  })  : assert(pageSize > 0, 'pageSize must be greater than zero.'),
        assert(options.isNotEmpty, "Options can't be empty"),
        theme = Theme.defaultTheme;

  FuzzyMultiSelect.withTheme({
    required this.prompt,
    required this.options,
    required this.theme,
    this.defaults,
    this.pageSize = 10,
    this.searchPlaceholder = 'Type to filter',
  })  : assert(pageSize > 0, 'pageSize must be greater than zero.'),
        assert(options.isNotEmpty, "Options can't be empty");

  final Theme theme;
  final String prompt;
  final List<String> options;
  final List<bool>? defaults;
  final int pageSize;
  final String searchPlaceholder;

  @override
  _FuzzyMultiSelectState createState() => _FuzzyMultiSelectState();
}

class _FuzzyMultiSelectState extends State<FuzzyMultiSelect> {
  late final Set<int> _selection;
  late List<_Result> _results;

  var _query = '';
  var _highlight = 0;
  var _top = 0;
  var _isMounted = false;

  @override
  void init() {
    super.init();
    _isMounted = true;

    if (component.options.isEmpty) {
      throw Exception("Options can't be empty");
    }

    if (component.defaults != null &&
        component.defaults!.length != component.options.length) {
      throw Exception(
        'Default selections have a different length of '
        '${component.defaults!.length} '
        'than options of ${component.options.length}',
      );
    }

    _selection = {
      if (component.defaults != null)
        for (var i = 0; i < component.defaults!.length; i++)
          if (component.defaults![i]) i,
    };
    _results = component.options.asMap().entries.map(
      (entry) {
        return _Result(
          index: entry.key,
          label: entry.value,
          score: 0,
          matches: const [],
        );
      },
    ).toList();

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
    final values = _selection.toList()..sort();
    final rendered = values.isEmpty
        ? component.theme.hintStyle('(none)')
        : values
            .map((index) => component.options[index])
            .map(component.theme.valueStyle)
            .join(', ');

    context.writeln(
      promptSuccess(
        theme: component.theme,
        message: component.prompt,
        value: rendered,
      ),
    );
    context.showCursor();

    _isMounted = false;
    super.dispose();
  }

  @override
  void render() {
    final summaryLine = StringBuffer()..write('Search: ');
    if (_query.isEmpty) {
      summaryLine.write(
        component.theme.hintStyle(component.searchPlaceholder),
      );
    } else {
      summaryLine.write(_query);
    }
    context.writeln(summaryLine.toString());

    final status = StringBuffer()..write('${_results.length} match');
    if (_results.length != 1) {
      status.write('es');
    }
    status
      ..write(' · ')
      ..write('${_selection.length} selected');

    context.writeln(
      component.theme.hintStyle(status.toString()),
    );

    context.writeln(
      component.theme.hintStyle(
        'Use Up/Down, PgUp/PgDn to navigate · Space toggles · Enter confirms',
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
      final isChecked = _selection.contains(result.index);
      final line = StringBuffer();

      if (component.theme.showActiveCursor) {
        line.write(
          isActive
              ? component.theme.activeItemPrefix
              : component.theme.inactiveItemPrefix,
        );
        line.write(' ');
      }

      line.write(
        isChecked
            ? component.theme.checkedItemPrefix
            : component.theme.uncheckedItemPrefix,
      );
      line.write(' ');
      line.write(_decorateLabel(result, isActive));
      context.writeln(line.toString());
    }

    if (end < _results.length) {
      final remaining = _results.length - end;
      context.writeln(
        component.theme.hintStyle('... $remaining more'),
      );
    }
  }

  @override
  List<int> interact() {
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
              _onQueryChanged(_query.substring(0, _query.length - 1));
            }
            break;
          case ControlCharacter.ctrlU:
            if (_query.isNotEmpty) {
              _onQueryChanged('');
            }
            break;
          case ControlCharacter.ctrlA:
            _selectAll();
            break;
          case ControlCharacter.enter:
            final values = _selection.toList()..sort();
            return values;
          default:
            break;
        }
        continue;
      }

      if (key.char == ' ') {
        _toggleSelection();
        continue;
      }

      if (key.char.isNotEmpty) {
        _onQueryChanged('$_query${key.char}');
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

  void _toggleSelection() {
    if (_results.isEmpty) {
      return;
    }
    final activeIndex = _results[_highlight].index;
    setState(() {
      if (_selection.contains(activeIndex)) {
        _selection.remove(activeIndex);
      } else {
        _selection.add(activeIndex);
      }
    });
  }

  void _selectAll() {
    if (_results.isEmpty) {
      return;
    }
    setState(() {
      _selection
        ..clear()
        ..addAll(_results.map((result) => result.index));
    });
  }

  void _onQueryChanged(String value) {
    _updateResults(value, resetNavigation: true);
  }

  void _updateResults(String nextQuery, {required bool resetNavigation}) {
    if (!_isMounted) {
      return;
    }

    final results = _buildResults(nextQuery);

    setState(() {
      _query = nextQuery;
      _results = results;

      if (_results.isEmpty) {
        _highlight = 0;
        _top = 0;
        return;
      }

      if (resetNavigation || _highlight >= _results.length) {
        _highlight = 0;
      }

      if (resetNavigation) {
        _top = 0;
      } else {
        if (_highlight < _top) {
          _top = _highlight;
        } else if (_highlight >= _top + component.pageSize) {
          _top = max(0, _highlight - component.pageSize + 1);
        }
        final maxTop = max(0, _results.length - component.pageSize);
        if (_top > maxTop) {
          _top = maxTop;
        }
      }
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
