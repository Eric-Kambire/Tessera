import 'dart:math' as math;
import '../../../../core/utils/latex_input_formatter.dart';
import '../../../../core/utils/math_input_normalizer.dart';
import '../entities/math_solution.dart';
import '../entities/solution_step.dart';

class RationalEquationSolver {
  static MathSolution? trySolve(String rawInput) {
    final normalized = normalizeForEngine(rawInput).replaceAll(' ', '');
    if (!normalized.contains('=')) return null;
    final parts = normalized.split('=');
    if (parts.length != 2) return null;

    final left = _parseRational(parts[0]);
    final right = _parseRational(parts[1]);
    if (left == null || right == null) return null;

    final restrictions = <double>[];
    final leftForbidden = left.den.root;
    if (leftForbidden != null) restrictions.add(leftForbidden);
    final rightForbidden = right.den.root;
    if (rightForbidden != null) restrictions.add(rightForbidden);

    final leftPoly = _multiply(left.num, right.den);
    final rightPoly = _multiply(right.num, left.den);
    final eq = _subtract(leftPoly, rightPoly);

    final inputLatex = latexFromRaw(rawInput);
    final restrictionsLatex = _restrictionsLatex(restrictions);
    final steps = <SolutionStep>[];

    if (restrictionsLatex.isNotEmpty) {
      steps.add(
        SolutionStep(
          inputLatex: inputLatex,
          description: 'Écarter les valeurs interdites du domaine.',
          outputLatex: restrictionsLatex,
        ),
      );
    }

    final crossLatex = _fractionLatex(left) + ' = ' + _fractionLatex(right);
    final multipliedLatex = _polyToLatex(leftPoly) + ' = ' + _polyToLatex(rightPoly);
    steps.add(
      SolutionStep(
        inputLatex: crossLatex,
        description: 'Effectuer la multiplication en croix.',
        outputLatex: multipliedLatex,
      ),
    );

    final simplifiedLatex = _polyToLatex(eq) + ' = 0';
    steps.add(
      SolutionStep(
        inputLatex: multipliedLatex,
        description: 'Ramener tous les termes dans un seul membre.',
        outputLatex: simplifiedLatex,
      ),
    );

    if (eq.a.abs() < 1e-9 && eq.b.abs() < 1e-9 && eq.c.abs() < 1e-9) {
      final domainLatex = restrictionsLatex.isEmpty
          ? r'x \in \mathbb{R}'
          : r'x \in \mathbb{R} \; \text{et} \; ' + restrictionsLatex;
      steps.add(
        SolutionStep(
          inputLatex: simplifiedLatex,
          description: 'L’équation est vraie pour tout x du domaine.',
          outputLatex: domainLatex,
        ),
      );
      return MathSolution(
        problemLatex: inputLatex,
        steps: steps,
        finalAnswerLatex: domainLatex,
      );
    }

    final solutions = _solvePolynomial(eq);
    if (solutions == null) return null;

    final filtered = solutions.where((x) => !_isForbidden(x, restrictions)).toList();
    final stepSolve = SolutionStep(
      inputLatex: simplifiedLatex,
      description: 'Résoudre l’équation algébrique obtenue.',
      outputLatex: _solutionLatex(solutions),
    );
    steps.add(stepSolve);

    final restrictionStep = _restrictionCheckLatex(solutions, filtered, restrictions);
    if (restrictionStep != null) {
      steps.add(
        SolutionStep(
          inputLatex: _solutionLatex(solutions),
          description: 'Vérifier les solutions au regard des restrictions.',
          outputLatex: restrictionStep,
        ),
      );
    }

    String finalAnswer;
    if (filtered.isEmpty) {
      finalAnswer = r'\text{Aucune solution}';
    } else {
      finalAnswer = _solutionLatex(filtered);
    }

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

  double? get root {
    if (a.abs() < 1e-9) return null;
    return -b / a;
  }
}

class _Poly {
  final double a;
  final double b;
  final double c;

  const _Poly(this.a, this.b, this.c);
}

class _Rational {
  final _Linear num;
  final _Linear den;

  const _Rational(this.num, this.den);
}

_Rational? _parseRational(String input) {
  final parts = _splitTopLevel(input, '/');
  if (parts == null) {
    final num = _parseLinear(input);
    if (num == null) return null;
    return _Rational(num, const _Linear(0, 1));
  }
  final num = _parseLinear(parts.a);
  final den = _parseLinear(parts.b);
  if (num == null || den == null) return null;
  if (den.a.abs() < 1e-9 && den.b.abs() < 1e-9) return null;
  return _Rational(num, den);
}

_Poly _multiply(_Linear left, _Linear right) {
  final a = left.a * right.a;
  final b = left.a * right.b + left.b * right.a;
  final c = left.b * right.b;
  return _Poly(a, b, c);
}

_Poly _subtract(_Poly left, _Poly right) {
  return _Poly(left.a - right.a, left.b - right.b, left.c - right.c);
}

List<double>? _solvePolynomial(_Poly poly) {
  final a = poly.a;
  final b = poly.b;
  final c = poly.c;
  if (a.abs() < 1e-9) {
    if (b.abs() < 1e-9) return <double>[];
    return <double>[-c / b];
  }
  final delta = b * b - 4 * a * c;
  if (delta < 0) return <double>[];
  final sqrt = delta == 0 ? 0.0 : math.sqrt(delta);
  final denom = 2 * a;
  final x1 = (-b - sqrt) / denom;
  final x2 = (-b + sqrt) / denom;
  return delta == 0 ? <double>[x1] : <double>[x1, x2];
}

_Linear? _parseLinear(String raw) {
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

class _StringPair {
  final String a;
  final String b;
  const _StringPair(this.a, this.b);
}

_StringPair? _splitTopLevel(String input, String sep) {
  var depth = 0;
  for (var i = 0; i < input.length; i++) {
    final ch = input[i];
    if (ch == '(') depth++;
    if (ch == ')') depth--;
    if (depth == 0 && ch == sep) {
      final left = input.substring(0, i);
      final right = input.substring(i + 1);
      if (left.isEmpty || right.isEmpty) return null;
      return _StringPair(left, right);
    }
  }
  return null;
}

String _fractionLatex(_Rational r) {
  return '\\frac{${_linearToLatex(r.num)}}{${_linearToLatex(r.den)}}';
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

String _polyToLatex(_Poly poly) {
  final buffer = StringBuffer();
  if (poly.a.abs() >= 1e-9) {
    if (poly.a == 1) {
      buffer.write('x^2');
    } else if (poly.a == -1) {
      buffer.write('-x^2');
    } else {
      buffer.write('${_fmt(poly.a)}x^2');
    }
  }
  if (poly.b.abs() >= 1e-9) {
    final sign = poly.b >= 0 ? '+' : '-';
    final abs = _fmt(poly.b.abs());
    final term = abs == '1' ? 'x' : '$abs' 'x';
    if (buffer.isEmpty) {
      buffer.write(poly.b >= 0 ? term : '-$term');
    } else {
      buffer.write(' $sign $term');
    }
  }
  if (poly.c.abs() >= 1e-9) {
    final sign = poly.c >= 0 ? '+' : '-';
    final abs = _fmt(poly.c.abs());
    if (buffer.isEmpty) {
      buffer.write(poly.c >= 0 ? abs : '-$abs');
    } else {
      buffer.write(' $sign $abs');
    }
  }
  if (buffer.isEmpty) return '0';
  return buffer.toString();
}

String _restrictionsLatex(List<double> values) {
  if (values.isEmpty) return '';
  final unique = <double>[];
  for (final v in values) {
    if (!unique.any((u) => (u - v).abs() < 1e-6)) {
      unique.add(v);
    }
  }
  final parts = unique.map((v) => r'x \neq ' + _fmt(v)).toList();
  return parts.join(r',\; ');
}

bool _isForbidden(double value, List<double> restrictions) {
  return restrictions.any((r) => (value - r).abs() < 1e-6);
}

String _solutionLatex(List<double> values) {
  if (values.isEmpty) {
    return r'\text{Aucune solution}';
  }
  if (values.length == 1) {
    return r'x = ' + _fmt(values.first);
  }
  return r'x_1 = ' + _fmt(values[0]) + r',\; x_2 = ' + _fmt(values[1]);
}

String? _restrictionCheckLatex(List<double> all, List<double> filtered, List<double> restrictions) {
  if (restrictions.isEmpty) return null;
  if (all.isEmpty) return null;

  if (filtered.length == all.length) {
    return r'\text{Toutes les solutions respectent le domaine.}';
  }

  final removed = all.where((x) => !filtered.any((y) => (y - x).abs() < 1e-6)).toList();
  if (removed.isEmpty) return null;
  final removedLatex = removed.map((v) => _fmt(v)).join(r',\; ');
  return r'\text{Exclure } ' + removedLatex + r' \text{ (valeurs interdites)}';
}

String _fmt(double value) {
  var text = value.toStringAsFixed(6);
  text = text.replaceAll(RegExp(r'0+$'), '');
  text = text.replaceAll(RegExp(r'\.$'), '');
  if (text == '-0') return '0';
  return text;
}
