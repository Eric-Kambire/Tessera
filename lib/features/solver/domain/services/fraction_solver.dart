import '../../../../core/utils/math_input_normalizer.dart';
import '../../../../core/utils/latex_input_formatter.dart';
import '../entities/math_solution.dart';
import '../entities/solution_step.dart';

class FractionSolver {
  static MathSolution? trySolve(String rawInput) {
    final normalized = normalizeForEngine(rawInput).replaceAll(' ', '');
    if (normalized.contains('=')) return null;

    final expr = _splitTopLevelOp(normalized);
    if (expr == null) {
      final single = _parseFraction(normalized);
      if (single == null) return null;
      return _simplifyFraction(rawInput, single);
    }

    final left = _parseFraction(expr.left);
    final right = _parseFraction(expr.right);
    if (left == null || right == null) return null;

    switch (expr.op) {
      case '+':
      case '-':
        return _addSub(rawInput, left, right, expr.op == '-');
      case '*':
        return _mul(rawInput, left, right);
      case '/':
        return _div(rawInput, left, right);
    }
    return null;
  }
}

class _Frac {
  final _Num num;
  final int den;

  const _Frac(this.num, this.den);
}

class _Num {
  final int coeff;
  final int power; // 0 = constant, 1 = x, 2 = x^2

  const _Num(this.coeff, this.power);
}

class _ExprSplit {
  final String left;
  final String right;
  final String op;

  const _ExprSplit(this.left, this.right, this.op);
}

_ExprSplit? _splitTopLevelOp(String input) {
  var depth = 0;
  for (var i = 0; i < input.length; i++) {
    final ch = input[i];
    if (ch == '(') depth++;
    if (ch == ')') depth--;
    if (depth == 0 && (ch == '+' || ch == '-' || ch == '*' || ch == '/')) {
      final left = input.substring(0, i);
      final right = input.substring(i + 1);
      if (left.isEmpty || right.isEmpty) return null;
      return _ExprSplit(left, right, ch);
    }
  }
  return null;
}

_Frac? _parseFraction(String input) {
  final cleaned = _stripParens(input);
  final parts = _splitTopLevel(cleaned, '/');
  if (parts == null) return null;
  final num = _parseNum(parts.a);
  final den = _parseDen(parts.b);
  if (num == null || den == null) return null;
  return _Frac(num, den);
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

class _StringPair {
  final String a;
  final String b;
  const _StringPair(this.a, this.b);
}

String _stripParens(String input) {
  if (input.startsWith('(') && input.endsWith(')')) {
    return input.substring(1, input.length - 1);
  }
  return input;
}

_Num? _parseNum(String raw) {
  final text = raw.replaceAll('*', '');
  if (text.contains('x^2')) {
    final coeffText = text.replaceAll('x^2', '');
    final coeff = _parseCoeff(coeffText);
    return coeff == null ? null : _Num(coeff, 2);
  }
  if (text.contains('x')) {
    final coeffText = text.replaceAll('x', '');
    final coeff = _parseCoeff(coeffText);
    return coeff == null ? null : _Num(coeff, 1);
  }
  final value = int.tryParse(text);
  if (value == null) return null;
  return _Num(value, 0);
}

int? _parseDen(String raw) {
  final text = raw.replaceAll('*', '');
  if (text.contains('x')) return null;
  return int.tryParse(text);
}

int? _parseCoeff(String raw) {
  if (raw.isEmpty || raw == '+') return 1;
  if (raw == '-') return -1;
  return int.tryParse(raw);
}

MathSolution _simplifyFraction(String rawInput, _Frac frac) {
  final reduced = _reduce(frac);
  final inputLatex = _toLatex(frac);
  final outputLatex = _toLatex(reduced);
  final changed = inputLatex != outputLatex;

  return MathSolution(
    problemLatex: latexFromRaw(rawInput),
    steps: [
      SolutionStep(
        inputLatex: inputLatex,
        description: changed ? 'Réduire la fraction' : 'Fraction déjà simplifiée',
        outputLatex: outputLatex,
      ),
    ],
    finalAnswerLatex: outputLatex,
  );
}

MathSolution _addSub(String rawInput, _Frac left, _Frac right, bool isSub) {
  if (left.num.power != right.num.power) return _fallback(rawInput);
  final denom = left.den * right.den;
  final sign = isSub ? -1 : 1;
  final newCoeff = left.num.coeff * right.den + sign * right.num.coeff * left.den;
  final newNum = _Num(newCoeff, left.num.power);
  final combined = _reduce(_Frac(newNum, denom));

  final inputLatex = _toLatex(left) + (isSub ? ' - ' : ' + ') + _toLatex(right);
  final stepLatex = '\\frac{' + _numLatex(newNum) + '}{' + denom.toString() + '}';
  final reducedLatex = _toLatex(combined);

  return MathSolution(
    problemLatex: inputLatex,
    steps: [
      SolutionStep(
        inputLatex: inputLatex,
        description: 'Mettre au même dénominateur',
        outputLatex: stepLatex,
        subSteps: [
          SolutionStep(
            inputLatex: inputLatex,
            description: 'Multiplier chaque fraction par le dénominateur manquant',
            outputLatex: stepLatex,
            isSubstep: true,
          ),
        ],
      ),
      if (stepLatex != reducedLatex)
        SolutionStep(
          inputLatex: stepLatex,
          description: 'Réduire la fraction',
          outputLatex: reducedLatex,
        ),
    ],
    finalAnswerLatex: reducedLatex,
  );
}

MathSolution _mul(String rawInput, _Frac left, _Frac right) {
  final power = left.num.power + right.num.power;
  final numCoeff = left.num.coeff * right.num.coeff;
  final denom = left.den * right.den;
  final combined = _reduce(_Frac(_Num(numCoeff, power), denom));

  final inputLatex = _toLatex(left) + ' \\times ' + _toLatex(right);
  final stepLatex = _toLatex(_Frac(_Num(numCoeff, power), denom));
  final reducedLatex = _toLatex(combined);

  return MathSolution(
    problemLatex: inputLatex,
    steps: [
      SolutionStep(
        inputLatex: inputLatex,
        description: 'Multiplier les fractions',
        outputLatex: stepLatex,
        subSteps: [
          SolutionStep(
            inputLatex: inputLatex,
            description: 'Multiplier les numérateurs et les dénominateurs',
            outputLatex: stepLatex,
            isSubstep: true,
          ),
        ],
      ),
      if (stepLatex != reducedLatex)
        SolutionStep(
          inputLatex: stepLatex,
          description: 'Réduire la fraction',
          outputLatex: reducedLatex,
        ),
    ],
    finalAnswerLatex: reducedLatex,
  );
}

MathSolution _div(String rawInput, _Frac left, _Frac right) {
  if (right.num.coeff == 0) return _fallback(rawInput);
  final power = left.num.power + right.num.power;
  final numCoeff = left.num.coeff * right.den;
  final denom = left.den * right.num.coeff.abs();
  final sign = right.num.coeff < 0 ? -1 : 1;
  final combined = _reduce(_Frac(_Num(numCoeff * sign, power), denom));

  final inputLatex = _toLatex(left) + ' \\div ' + _toLatex(right);
  final stepLatex = _toLatex(_Frac(_Num(numCoeff * sign, power), denom));
  final reducedLatex = _toLatex(combined);

  return MathSolution(
    problemLatex: inputLatex,
    steps: [
      SolutionStep(
        inputLatex: inputLatex,
        description: 'Diviser les fractions',
        outputLatex: stepLatex,
        subSteps: [
          SolutionStep(
            inputLatex: inputLatex,
            description: 'Multiplier par l’inverse de la deuxième fraction',
            outputLatex: stepLatex,
            isSubstep: true,
          ),
        ],
      ),
      if (stepLatex != reducedLatex)
        SolutionStep(
          inputLatex: stepLatex,
          description: 'Réduire la fraction',
          outputLatex: reducedLatex,
        ),
    ],
    finalAnswerLatex: reducedLatex,
  );
}

MathSolution _fallback(String rawInput) {
  final latex = latexFromRaw(rawInput);
  return MathSolution(
    problemLatex: latex,
    steps: [
      SolutionStep(
        inputLatex: latex,
        description: 'Simplification non supportée pour cette forme',
        outputLatex: latex,
      ),
    ],
    finalAnswerLatex: latex,
  );
}

_Frac _reduce(_Frac frac) {
  if (frac.num.power != 0) return frac;
  final g = _gcd(frac.num.coeff.abs(), frac.den.abs());
  if (g == 0) return frac;
  return _Frac(_Num(frac.num.coeff ~/ g, frac.num.power), frac.den ~/ g);
}

int _gcd(int a, int b) {
  var x = a.abs();
  var y = b.abs();
  while (y != 0) {
    final t = x % y;
    x = y;
    y = t;
  }
  return x;
}

String _toLatex(_Frac frac) {
  return '\\frac{' + _numLatex(frac.num) + '}{' + frac.den.toString() + '}';
}

String _numLatex(_Num num) {
  final coeff = num.coeff;
  final coeffText = coeff == 1 && num.power > 0 ? '' : coeff == -1 && num.power > 0 ? '-' : coeff.toString();
  if (num.power == 0) return coeff.toString();
  if (num.power == 1) return coeffText + 'x';
  return coeffText + 'x^2';
}
