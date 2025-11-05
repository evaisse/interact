/// Fuzzy searching utilities for interactive selectors.
class FuzzyMatch {
  FuzzyMatch({
    required this.score,
    required this.positions,
  });

  final double score;
  final List<int> positions;
}

class FuzzyMatcher {
  const FuzzyMatcher._();

  /// Returns [FuzzyMatch] when [pattern] loosely matches [candidate].
  ///
  /// The scoring model is intentionally simple but rewards consecutive matches,
  /// matches near the start of the string, and matches that begin on
  /// word boundaries.
  static FuzzyMatch? evaluate(String pattern, String candidate) {
    final query = pattern.trim().toLowerCase();
    if (query.isEmpty) {
      return FuzzyMatch(score: 0, positions: const []);
    }

    final target = candidate.toLowerCase();
    final positions = <int>[];
    var score = 0.0;
    var consecutive = 0;
    var patternIndex = 0;
    var lastMatch = -1;

    for (var i = 0; i < target.length; i++) {
      if (patternIndex >= query.length) {
        break;
      }

      if (target[i] != query[patternIndex]) {
        consecutive = 0;
        continue;
      }

      positions.add(i);
      score += 1.0;
      if (lastMatch != -1 && i == lastMatch + 1) {
        consecutive += 1;
        score += 0.5 * consecutive;
      } else {
        consecutive = 0;
      }

      if (_isWordBoundary(target, i)) {
        score += 0.6;
      }
      if (i == 0) {
        score += 0.8;
      }

      lastMatch = i;
      patternIndex++;
    }

    if (patternIndex != query.length) {
      return null;
    }

    if (positions.isNotEmpty) {
      score -= positions.first * 0.05;
    }
    score -= (candidate.length - positions.length) * 0.01;

    return FuzzyMatch(score: score, positions: positions);
  }

  static bool _isWordBoundary(String target, int index) {
    if (index == 0) {
      return true;
    }
    final prev = target[index - 1];
    return prev == ' ' ||
        prev == '-' ||
        prev == '_' ||
        prev == '/' ||
        prev == '.';
  }
}
