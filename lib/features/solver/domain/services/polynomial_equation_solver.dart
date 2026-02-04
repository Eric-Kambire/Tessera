import '../../../../core/utils/latex_input_formatter.dart';
import '../../../../core/utils/rational_formatter.dart';
import '../../../../core/utils/math_input_normalizer.dart';
import '../entities/math_solution.dart';
import '../entities/solution_step.dart';

class PolynomialEquationSolver {
  static MathSolution? trySolve(String rawInput) {
    final normalized = normalizeForEngine(rawInput).replaceAll(' ', '');
    if (!normalized.contains('=')) return null;
    final parts = normalized.split('=');
    if (parts.length != 2) return null;

    var left = parts[0];
    var right = parts[1];

    if (left == '0' && right != '0') {
      left = right;
      right = '0';
    }

    if (right != '0') return null;

    final factors = _splitTopLevelProduct(left);
    if (factors.length != 2) return null;

    final first = _parseLinearFactor(factors[0]);
    final second = _parseLinearFactor(factors[1]);
    if (first == null || second == null) return null;

    if (first.a.abs() < 1e-9 || second.a.abs() < 1e-9) return null;

    final x1 = -first.b / first.a;
    final x2 = -second.b / second.a;

    final inputLatex = latexFromRaw(rawInput);
    final eq1 = _linearToLatex(first) + r' = 0';
    final eq2 = _linearToLatex(second) + r' = 0';

    final steps = <SolutionStep>[
      SolutionStep(
        inputLatex: inputLatex,
        description: 'Appliquer la propriété du produit nul.',
        outputLatex: '$eq1\\; \\text{ou} \\; $eq2',
      ),
      SolutionStep(
        inputLatex: eq1,
        description: 'Résoudre la première équation linéaire.',
        outputLatex: r'x = ' + _fmt(x1),
      ),
      SolutionStep(
        inputLatex: eq2,
        description: 'Résoudre la deuxième équation linéaire.',
        outputLatex: r'x = ' + _fmt(x2),
      ),
    ];

    final finalAnswer = x1 == x2
        ? r'x = ' + formatValueFractionFirst(x1)
        : formatSolutionsFractionFirst([x1, x2]);

    return MathSolution(
      problemLatex: inputLatex,
      steps: steps,
      finalAnswerLatex: finalAnswer,
    );
  }
}

class _Linear {
  final double a;
  final double b;

  const _Linear(this.a, this.b);
}

List<String> _splitTopLevelProduct(String input) {
  final cleaned = _stripOuterParens(input);
  final direct = RegExp(r'^\(([^()]+)\)\(([^()]+)\)$').firstMatch(cleaned);
  if (direct != null) {
    final left = direct.group(1) ?? '';
    final right = direct.group(2) ?? '';
    if (left.isNotEmpty && right.isNotEmpty) {
      return ['($left)', '($right)'];
    }
  }
  final parts = <String>[];
  var depth = 0;
  var start = 0;
  for (var i = 0; i < cleaned.length; i++) {
    final ch = cleaned[i];
    if (ch == '(') depth++;
    if (ch == ')') depth--;
    if (depth == 0 && ch == '*') {
      parts.add(cleaned.substring(start, i));
      start = i + 1;
    }
  }
  parts.add(cleaned.substring(start));
  return parts.where((p) => p.isNotEmpty).toList();
}

_Linear? _parseLinearFactor(String raw) {
  final text = _stripOuterParens(raw.replaceAll('*', ''));
  if (text.isEmpty) return null;

  final terms = RegExp(r'[+-]?[^+-]+')
      .allMatches(text)
      .map((m) => m.group(0) ?? '')
      .where((t) => t.isNotEmpty)
      .toList();

  double a = 0;
  double b = 0;
  for (final term in terms) {
    if (term.contains('x^2')) return null;
    if (term.contains('x')) {
      final coeffText = term.replaceAll('x', '');
      final coeff = _parseCoeff(coeffText);
      if (coeff == null) return null;
      a += coeff;
      continue;
    }
    final value = double.tryParse(term);
    if (value == null) return null;
    b += value;
  }
  return _Linear(a, b);
}

double? _parseCoeff(String raw) {
  if (raw.isEmpty || raw == '+') return 1;
  if (raw == '-') return -1;
  return double.tryParse(raw);
}

String _stripOuterParens(String input) {
  if (input.startsWith('(') && input.endsWith(')')) {
    return input.substring(1, input.length - 1);
  }
  return input;
}

String _linearToLatex(_Linear lin) {
  final a = lin.a;
  final b = lin.b;
  final buffer = StringBuffer();
  if (a.abs() >= 1e-9) {
    if (a == -1) {
      buffer.write('-x');
    } else if (a == 1) {
      buffer.write('x');
    } else {
      buffer.write('${_fmt(a)}x');
    }
  }
  if (b.abs() >= 1e-9) {
    final sign = b >= 0 ? '+' : '-';
    final abs = _fmt(b.abs());
    if (buffer.isEmpty) {
      buffer.write(b >= 0 ? abs : '-$abs');
    } else {
      buffer.write(' $sign $abs');
    }
  }
  if (buffer.isEmpty) return '0';
  return buffer.toString();
}

String _fmt(double value) {
  var text = value.toStringAsFixed(6);
  text = text.replaceAll(RegExp(r'0+$'), '');
  text = text.replaceAll(RegExp(r'\.$'), '');
  if (text == '-0') return '0';
  return text;
}
