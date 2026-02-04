import '../../../../core/utils/latex_input_formatter.dart';
import '../../../../core/utils/math_input_normalizer.dart';
import '../entities/math_solution.dart';
import '../entities/solution_step.dart';

class QuadraticFactoringSolver {
  static MathSolution? trySolve(String rawInput) {
    final normalized = normalizeForEngine(rawInput).replaceAll(' ', '');
    if (!normalized.contains('=')) return null;
    final parts = normalized.split('=');
    if (parts.length != 2) return null;

    final left = _parsePoly(parts[0]);
    final right = _parsePoly(parts[1]);
    if (left == null || right == null) return null;

    final a = left.a - right.a;
    final b = left.b - right.b;
    final c = left.c - right.c;
    if (a == 0) return null;

    final intA = _toInt(a);
    final intB = _toInt(b);
    final intC = _toInt(c);
    if (intA == null || intB == null || intC == null) return null;

    final factorPair = _findFactorPair(intA, intB, intC);
    if (factorPair == null) return null;

    final r1 = factorPair.r1;
    final r2 = factorPair.r2;

    final inputLatex = latexFromRaw(rawInput);
    final standard = _formatQuadratic(intA, intB, intC) + r' = 0';
    final factored = _formatFactored(intA, r1, r2) + r' = 0';

    final steps = <SolutionStep>[
      SolutionStep(
        inputLatex: inputLatex,
        description: 'Ramener l’équation à la forme ax^2 + bx + c = 0.',
        outputLatex: standard,
      ),
      SolutionStep(
        inputLatex: standard,
        description: 'Factoriser le trinôme du second degré.',
        outputLatex: factored,
      ),
      SolutionStep(
        inputLatex: factored,
        description: 'Appliquer la propriété du produit nul.',
        outputLatex: _factorEquationLatex(r1, r2),
      ),
      SolutionStep(
        inputLatex: _linearEquationLatex(r1),
        description: 'Résoudre la première équation linéaire.',
        outputLatex: r'x = ' + _fmt(r1.toDouble()),
      ),
      SolutionStep(
        inputLatex: _linearEquationLatex(r2),
        description: 'Résoudre la deuxième équation linéaire.',
        outputLatex: r'x = ' + _fmt(r2.toDouble()),
      ),
    ];

    final finalAnswer = r1 == r2
        ? r'x = ' + _fmt(r1.toDouble())
        : r'x_1 = ' + _fmt(r1.toDouble()) + r',\; x_2 = ' + _fmt(r2.toDouble());

    return MathSolution(
      problemLatex: inputLatex,
      steps: steps,
      finalAnswerLatex: finalAnswer,
    );
  }
}

class _Poly {
  final int a;
  final int b;
  final int c;

  const _Poly(this.a, this.b, this.c);
}

_Poly? _parsePoly(String expr) {
  if (expr.isEmpty) return const _Poly(0, 0, 0);
  if (RegExp(r'[a-wyzA-WYZ]').hasMatch(expr)) return null;

  final terms = RegExp(r'[+-]?[^+-]+')
      .allMatches(expr)
      .map((m) => m.group(0) ?? '')
      .where((t) => t.isNotEmpty)
      .toList();

  int a = 0;
  int b = 0;
  int c = 0;

  for (final term in terms) {
    if (term.contains('x^2')) {
      final coeff = term.replaceAll('x^2', '');
      final value = _parseCoeff(coeff);
      if (value == null) return null;
      a += value;
      continue;
    }
    if (term.contains('x')) {
      final coeff = term.replaceAll('x', '');
      final value = _parseCoeff(coeff);
      if (value == null) return null;
      b += value;
      continue;
    }
    final value = int.tryParse(term);
    if (value == null) return null;
    c += value;
  }

  return _Poly(a, b, c);
}

int? _parseCoeff(String raw) {
  if (raw.isEmpty || raw == '+') return 1;
  if (raw == '-') return -1;
  return int.tryParse(raw);
}

int? _toInt(num value) {
  if (value is int) return value;
  if (value is double) {
    final rounded = value.round();
    if ((value - rounded).abs() < 1e-9) return rounded;
  }
  return null;
}

class _Roots {
  final int r1;
  final int r2;

  const _Roots(this.r1, this.r2);
}

_Roots? _findFactorPair(int a, int b, int c) {
  if (a == 0) return null;
  if (c == 0) {
    final r1 = 0;
    final r2 = (-b / a);
    if (r2 % 1 == 0) {
      return _Roots(r1, r2.toInt());
    }
    return null;
  }

  final divisors = _divisors(c);
  for (final r1 in divisors) {
    final value = a * r1 * r1 + b * r1 + c;
    if (value != 0) continue;
    final denom = a * r1;
    if (denom == 0) continue;
    if (c % denom != 0) continue;
    final r2 = c ~/ denom;
    if (a * r2 * r2 + b * r2 + c != 0) continue;
    return _Roots(r1, r2);
  }
  return null;
}

int _abs(int v) => v < 0 ? -v : v;

List<int> _divisors(int value) {
  final v = _abs(value);
  final result = <int>[];
  for (var i = 1; i <= v; i++) {
    if (v % i == 0) {
      result.add(i);
      result.add(-i);
    }
  }
  return result;
}

String _formatQuadratic(int a, int b, int c) {
  final buffer = StringBuffer();
  buffer.write(_formatTerm(a, 'x^2', leading: true));
  buffer.write(_formatTerm(b, 'x'));
  buffer.write(_formatConst(c));
  return buffer.toString();
}

String _formatTerm(int coeff, String symbol, {bool leading = false}) {
  if (coeff == 0) return '';
  final sign = coeff >= 0 ? '+' : '-';
  final abs = coeff.abs();
  final coeffText = (abs == 1) ? '' : abs.toString();
  if (leading) {
    return (coeff < 0 ? '-' : '') + coeffText + symbol;
  }
  return ' ' + sign + ' ' + coeffText + symbol;
}

String _formatConst(int value) {
  if (value == 0) return '';
  final sign = value >= 0 ? '+' : '-';
  final abs = value.abs().toString();
  return ' ' + sign + ' ' + abs;
}

String _formatFactored(int a, int r1, int r2) {
  final aText = a == 1 ? '' : (a == -1 ? '-' : a.toString());
  final first = _factorLatex(r1);
  final second = _factorLatex(r2);
  return aText.isEmpty ? '$first$second' : '$aText$first$second';
}

String _factorLatex(int root) {
  if (root == 0) return '(x)';
  final sign = root > 0 ? '-' : '+';
  final abs = _abs(root);
  return '(x $sign $abs)';
}

String _factorEquationLatex(int r1, int r2) {
  final f1 = _linearEquationLatex(r1);
  final f2 = _linearEquationLatex(r2);
  return '$f1\\; \\text{ou} \\; $f2';
}

String _linearEquationLatex(int root) {
  final sign = root > 0 ? '-' : '+';
  final abs = _abs(root);
  return 'x $sign $abs = 0';
}

String _fmt(double value) {
  var text = value.toStringAsFixed(6);
  text = text.replaceAll(RegExp(r'0+$'), '');
  text = text.replaceAll(RegExp(r'\.$'), '');
  if (text == '-0') return '0';
  return text;
}
