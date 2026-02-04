import 'dart:math' as math;
import '../../../../core/utils/latex_input_formatter.dart';
import '../entities/math_solution.dart';
import '../entities/solution_step.dart';

class QuadraticSolver {
  static MathSolution? trySolve(String rawInput, String normalizedInput) {
    final cleaned = _clean(normalizedInput);
    final parts = cleaned.split('=');
    if (parts.length != 2) return null;

    final left = _parsePoly(parts[0]);
    final right = _parsePoly(parts[1]);
    if (left == null || right == null) return null;

    final a = left.a - right.a;
    final b = left.b - right.b;
    final c = left.c - right.c;

    if (a.abs() < 1e-9) return null;

    final delta = b * b - 4 * a * c;
    final problemLatex = latexFromRaw(rawInput);

    final standardForm = _formatQuadratic(a, b, c);
    final h = -b / (2 * a);
    final k = c - (b * b) / (4 * a);
    final canonicalForm = _formatCanonical(a, h, k);

    final steps = <SolutionStep>[
      SolutionStep(
        inputLatex: problemLatex,
        description: 'Ramener l’équation à la forme ax^2 + bx + c = 0.',
        outputLatex: standardForm + r' = 0',
      ),
      SolutionStep(
        inputLatex: standardForm + r' = 0',
        description: 'Mettre le trinôme sous forme canonique.',
        outputLatex: canonicalForm + r' = 0',
      ),
      SolutionStep(
        inputLatex: standardForm + r' = 0',
        description: 'Calculer le discriminant.',
        outputLatex: r'\Delta = ' + _fmt(b) + r'^2 - 4\times' + _fmt(a) + r'\times' + _fmt(c) + r' = ' + _fmt(delta),
      ),
    ];

    if (delta < 0) {
      return MathSolution(
        problemLatex: problemLatex,
        steps: steps,
        finalAnswerLatex: r'\text{Aucune solution réelle}',
      );
    }

    final sqrtDelta = math.sqrt(delta);
    final denom = 2 * a;
    final x1 = (-b - sqrtDelta) / denom;
    final x2 = (-b + sqrtDelta) / denom;

    final formula = r'x = \frac{-b \pm \sqrt{\Delta}}{2a}';
    final valueLine = delta == 0
        ? r'x = ' + _fmt(x1)
        : r'x_1 = ' + _fmt(x1) + r',\; x_2 = ' + _fmt(x2);

    steps.add(
      SolutionStep(
        inputLatex: r'\Delta = ' + _fmt(delta),
        description: 'Appliquer la formule quadratique.',
        outputLatex: formula + r'\;\Rightarrow\;' + valueLine,
      ),
    );

    final finalAnswer = delta == 0
        ? r'x = ' + _fmt(x1)
        : r'x_1 = ' + _fmt(x1) + r',\; x_2 = ' + _fmt(x2);

    return MathSolution(
      problemLatex: problemLatex,
      steps: steps,
      finalAnswerLatex: finalAnswer,
    );
  }
}

class _Poly {
  final double a;
  final double b;
  final double c;

  const _Poly(this.a, this.b, this.c);
}

String _clean(String input) {
  return input.replaceAll(' ', '').replaceAll('*', '');
}

_Poly? _parsePoly(String expr) {
  if (expr.isEmpty) return const _Poly(0, 0, 0);
  if (RegExp(r'[a-wyzA-WYZ]').hasMatch(expr)) return null;

  final terms = RegExp(r'[+-]?[^+-]+').allMatches(expr).map((m) => m.group(0) ?? '').where((t) => t.isNotEmpty).toList();
  double a = 0;
  double b = 0;
  double c = 0;

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
    final value = double.tryParse(term);
    if (value == null) return null;
    c += value;
  }

  return _Poly(a, b, c);
}

double? _parseCoeff(String raw) {
  if (raw.isEmpty || raw == '+') return 1;
  if (raw == '-') return -1;
  return double.tryParse(raw);
}

String _fmt(double value) {
  var text = value.toStringAsFixed(6);
  text = text.replaceAll(RegExp(r'0+$'), '');
  text = text.replaceAll(RegExp(r'\.$'), '');
  if (text == '-0') return '0';
  return text;
}

String _formatQuadratic(double a, double b, double c) {
  final buffer = StringBuffer();
  buffer.write(_formatTerm(a, 'x^2', leading: true));
  buffer.write(_formatTerm(b, 'x'));
  buffer.write(_formatConst(c));
  return buffer.toString();
}

String _formatTerm(double coeff, String symbol, {bool leading = false}) {
  if (coeff.abs() < 1e-9) return '';
  final sign = coeff >= 0 ? '+' : '-';
  final abs = coeff.abs();
  final coeffText = (abs == 1) ? '' : _fmt(abs);
  if (leading) {
    return (coeff < 0 ? '-' : '') + coeffText + symbol;
  }
  return ' ' + sign + ' ' + coeffText + symbol;
}

String _formatConst(double value) {
  if (value.abs() < 1e-9) return '';
  final sign = value >= 0 ? '+' : '-';
  final abs = _fmt(value.abs());
  return ' ' + sign + ' ' + abs;
}

String _formatCanonical(double a, double h, double k) {
  final aText = _fmt(a);
  final hText = _fmt(h);
  final kText = _fmt(k);
  final signH = h >= 0 ? '-' : '+';
  final absH = _fmt(h.abs());
  final inside = 'x $signH $absH';
  final base = (aText == '1') ? '' : (aText == '-1' ? '-' : aText);
  final squared = '${base}(${inside})^2';
  if (k.abs() < 1e-9) return squared;
  final signK = k >= 0 ? '+' : '-';
  final absK = _fmt(k.abs());
  return '$squared $signK $absK';
}
