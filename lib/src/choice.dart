import 'package:interact/src/framework/framework.dart';
import 'package:interact/src/fuzzy_multi_select.dart';
import 'package:interact/src/fuzzy_select.dart';
import 'package:interact/src/multi_select.dart';
import 'package:interact/src/select.dart';
import 'package:interact/src/theme/theme.dart';

/// Controls how [Choice] gathers user input.
enum ChoiceMode {
  /// Returns the index of the selected option.
  single,

  /// Returns indices for all toggled options.
  multiple,
}

/// A unified selector component configurable for single/multi choice and
/// optional fuzzy search.
///
/// ```dart
/// final languages = ['Dart', 'Rust', 'Go'];
/// final choice = Choice(
///   prompt: 'Pick your next language',
///   options: languages,
///   mode: ChoiceMode.single,
///   useFuzzySearch: true,
/// ).interact() as int;
///
/// print('Building with ${languages[choice]}');
/// ```
class Choice extends Component<dynamic> {
  Choice({
    required this.prompt,
    required this.options,
    this.mode = ChoiceMode.single,
    this.useFuzzySearch = false,
    this.initialIndex = 0,
    this.defaults,
    this.pageSize = 10,
    this.searchPlaceholder = 'Type to filter',
    Theme? theme,
  })  : assert(options.isNotEmpty, "Options can't be empty"),
        theme = theme ?? Theme.defaultTheme,
        _component = _resolve(
          prompt: prompt,
          options: options,
          mode: mode,
          useFuzzySearch: useFuzzySearch,
          initialIndex: initialIndex,
          defaults: defaults,
          pageSize: pageSize,
          searchPlaceholder: searchPlaceholder,
          theme: theme ?? Theme.defaultTheme,
        ) {
    if (mode == ChoiceMode.multiple &&
        defaults != null &&
        defaults!.length != options.length) {
      throw Exception(
        'Default selections have a different length of '
        '${defaults!.length} than options of ${options.length}',
      );
    }
    if (mode == ChoiceMode.single &&
        (initialIndex < 0 || initialIndex >= options.length)) {
      throw Exception('Initial index is out of range');
    }
  }

  final String prompt;
  final List<String> options;
  final ChoiceMode mode;
  final bool useFuzzySearch;
  final int initialIndex;
  final List<bool>? defaults;
  final int pageSize;
  final String searchPlaceholder;
  final Theme theme;
  final Component<dynamic> _component;

  /// Exposes the underlying component used to render the choice.
  Component<dynamic> get delegate => _component;

  static Component<dynamic> _resolve({
    required String prompt,
    required List<String> options,
    required ChoiceMode mode,
    required bool useFuzzySearch,
    required int initialIndex,
    required List<bool>? defaults,
    required int pageSize,
    required String searchPlaceholder,
    required Theme theme,
  }) {
    switch (mode) {
      case ChoiceMode.multiple:
        if (useFuzzySearch) {
          return FuzzyMultiSelect.withTheme(
            prompt: prompt,
            options: options,
            defaults: defaults,
            pageSize: pageSize,
            searchPlaceholder: searchPlaceholder,
            theme: theme,
          );
        }
        return MultiSelect.withTheme(
          prompt: prompt,
          options: options,
          defaults: defaults,
          theme: theme,
        );
      case ChoiceMode.single:
        if (useFuzzySearch) {
          return FuzzySelect.withTheme(
            prompt: prompt,
            options: options,
            initialIndex: initialIndex,
            pageSize: pageSize,
            searchPlaceholder: searchPlaceholder,
            theme: theme,
          );
        }
        return Select.withTheme(
          prompt: prompt,
          options: options,
          initialIndex: initialIndex,
          theme: theme,
        );
    }
  }

  @override
  State createState() => _component.createState();

  @override
  void disposeState(State state) => _component.disposeState(state);

  @override
  State pipeState(State state) => _component.pipeState(state);

  @override
  dynamic interact() => _component.interact();
}
