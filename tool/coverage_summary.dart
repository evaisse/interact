import 'dart:io';

double _parseMinThreshold(List<String> args) {
  for (var i = 0; i < args.length; i++) {
    if (args[i] == '--min' && i + 1 < args.length) {
      return double.parse(args[i + 1]);
    }
  }
  return double.nan;
}

void main(List<String> args) {
  const reportPath = 'coverage/lcov.info';
  final minThreshold = _parseMinThreshold(args);

  final file = File(reportPath);
  if (!file.existsSync()) {
    stderr.writeln('Coverage report not found at $reportPath.');
    exit(1);
  }

  var covered = 0;
  var total = 0;

  for (final line in file.readAsLinesSync()) {
    if (line.startsWith('DA:')) {
      total++;
      final parts = line.substring(3).split(',');
      if (parts.length == 2 && int.tryParse(parts[1]) != null) {
        final hit = int.parse(parts[1]);
        if (hit > 0) {
          covered++;
        }
      }
    }
  }

  final coverage = total == 0 ? 100.0 : covered / total * 100;
  final formatted = coverage.toStringAsFixed(2);

  stdout.writeln(formatted);

  if (!minThreshold.isNaN && coverage < minThreshold) {
    stderr.writeln(
      'Coverage $formatted% is below required threshold '
      '${minThreshold.toStringAsFixed(2)}%.',
    );
    exit(1);
  }
}
