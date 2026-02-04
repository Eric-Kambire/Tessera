import '../../../../core/utils/latex_input_formatter.dart';
import '../entities/math_solution.dart';
import '../entities/solution_step.dart';

class QuadraticCompletingSquareSolver {
  static MathSolution? trySolve(String rawInput, String normalizedInput) {
    final cleaned = _clean(normalizedInput);
    final parts = cleaned.split('=');
    if (parts.length != 2) return null;

    final left = _parsePoly(parts[0]);
    final right = _parsePoly(parts[1]);
    if (left == null || right == null) return null;

    var a = left.a - right.a;
    var b = left.b - right.b;
    var c = left.c - right.c;
    if (a.abs() < 1e-9) return null;

    final inputLatex = latexFromRaw(rawInput);
    final steps = <SolutionStep>[];

    steps.add(
      SolutionStep(
        inputLatex: inputLatex,
        description: 'Ramener l’équation à la forme ax^2 + bx + c = 0.',
        outputLatex: _formatQuadratic(a, b, c) + r' = 0',
      ),
    );

    if (a.abs() != 1) {
      final b2 = b / a;
      final c2 = c / a;
      steps.add(
        SolutionStep(
          inputLatex: _formatQuadratic(a, b, c) + r' = 0',
          description: 'Diviser par a pour obtenir un coefficient directeur unitaire.',
          outputLatex: _formatQuadratic(1, b2, c2) + r' = 0',
        ),
      );
      a = 1;
      b = b2;
      c = c2;
    }

    steps.add(
      SolutionStep(
        inputLatex: _formatQuadratic(a, b, c) + r' = 0',
        description: 'Isoler les termes en x.',
        outputLatex: r'x^2 ' + _formatLinearTail(b) + r' = ' + _fmt(-c),
      ),
    );

    final h = b / 2;
    final add = h * h;
    steps.add(
      SolutionStep(
        inputLatex: r'x^2 ' + _formatLinearTail(b) + r' = ' + _fmt(-c),
        description: 'Ajouter le carré de la moitié du coefficient de x aux deux membres.',
        outputLatex: r'x^2 ' + _formatLinearTail(b) + r' + ' + _fmt(add) + r' = ' + _fmt(-c + add),
      ),
    );

    final leftSquare = r'(x ' + _signLatex(h, negativeSymbol: '-') + ' ' + _fmt(h.abs()) + r')^2';
    final rightValue = -c + add;
    steps.add(
      SolutionStep(
        inputLatex: r'x^2 ' + _formatLinearTail(b) + r' + ' + _fmt(add) + r' = ' + _fmt(-c + add),
        description: 'Factoriser le membre de gauche en carré parfait.',
        outputLatex: leftSquare + r' = ' + _fmt(rightValue),
      ),
    );

    steps.add(
      SolutionStep(
        inputLatex: leftSquare + r' = ' + _fmt(rightValue),
        description: 'Extraire la racine carrée des deux membres.',
        outputLatex: r'x ' + _signLatex(h, negativeSymbol: '-') + ' ' + _fmt(h.abs()) + r' = \pm\sqrt{' + _fmt(rightValue) + r'}',
      ),
    );

    final x1 = -h - _sqrt(rightValue);
    final x2 = -h + _sqrt(rightValue);
    final finalAnswer = (x1 - x2).abs() < 1e-9
        ? r'x = ' + _fmt(x1)
        : r'x_1 = ' + _fmt(x1) + r',\; x_2 = ' + _fmt(x2);

    steps.add(
      SolutionStep(
        inputLatex: r'x ' + _signLatex(h, negativeSymbol: '-') + ' ' + _fmt(h.abs()) + r' = \pm\sqrt{' + _fmt(rightValue) + r'}',
        description: 'Isoler x.',
        outputLatex: finalAnswer,
      ),
    );

    return MathSolution(
      problemLatex: inputLatex,
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

String _formatLinearTail(double b) {
  if (b.abs() < 1e-9) return '';
  final sign = b >= 0 ? '+' : '-';
  final abs = _fmt(b.abs());
  return '$sign $abs x';
}

String _signLatex(double value, {required String negativeSymbol}) {
  if (value >= 0) {
    return negativeSymbol;
  }
  return '+';
}

double _sqrt(double value) {
  if (value < 0) return double.nan;
  if (value == 0) return 0;
  var x = value;
  for (var i = 0; i < 12; i++) {
    x = 0.5 * (x + value / x);
  }
  return x;
}

String _fmt(double value) {
  var text = value.toStringAsFixed(6);
  text = text.replaceAll(RegExp(r'0+$'), '');
  text = text.replaceAll(RegExp(r'\.$'), '');
  if (text == '-0') return '0';
  return text;
}
