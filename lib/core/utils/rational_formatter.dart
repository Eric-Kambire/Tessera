import 'dart:math' as math;

String formatSolutionsFractionFirst(List<double> values) {
  if (values.isEmpty) return r'\text{Aucune solution}';
  if (values.length == 1) {
    return r'x = ' + formatValueFractionFirst(values.first);
  }
  if (values.length == 2) {
    return r'x_1 = ' +
        formatValueFractionFirst(values[0]) +
        r',\; x_2 = ' +
        formatValueFractionFirst(values[1]);
  }
  final parts = values.map(formatValueFractionFirst).toList();
  return r'x \in \{' + parts.join(r',\; ') + '}';
}

String formatValueFractionFirst(double value) {
  if (_isNearInt(value)) {
    return _fmt(value);
  }
  final fraction = _approximateFraction(value);
  if (fraction == null) {
    return _fmt(value);
  }
  final fracLatex = r'\frac{' + fraction.n.toString() + '}{' + fraction.d.toString() + '}';
  return fracLatex + r'\approx ' + _fmt(value);
}

bool _isNearInt(double value) => (value - value.roundToDouble()).abs() < 1e-9;

_Rational? _approximateFraction(double value, {int maxDen = 1000, double tol = 1e-6}) {
  if (value.isNaN || value.isInfinite) return null;
  final sign = value < 0 ? -1 : 1;
  var x = value.abs();
  var a0 = x.floor();
  var p0 = 1, q0 = 0;
  var p1 = a0, q1 = 1;

  if ((x - a0).abs() < tol) {
    return _Rational(sign * a0, 1);
  }

  var iter = 0;
  while (iter < 20) {
    iter++;
    final frac = x - a0;
    if (frac.abs() < tol) break;
    x = 1 / frac;
    final a = x.floor();
    final p2 = a * p1 + p0;
    final q2 = a * q1 + q0;
    if (q2 > maxDen) break;
    final approx = p2 / q2;
    if ((approx - (value.abs())).abs() < tol) {
      final n = sign * p2;
      final g = _gcd(n.abs(), q2);
      return _Rational(n ~/ g, q2 ~/ g);
    }
    p0 = p1;
    q0 = q1;
    p1 = p2;
    q1 = q2;
    a0 = a;
  }

  final n = sign * p1;
  final g = _gcd(n.abs(), q1);
  final best = _Rational(n ~/ g, q1 ~/ g);
  final approx = best.n / best.d;
  if ((approx - value).abs() < tol) return best;
  return null;
}

int _gcd(int a, int b) {
  var x = a;
  var y = b;
  while (y != 0) {
    final t = x % y;
    x = y;
    y = t;
  }
  return x == 0 ? 1 : x;
}

String _fmt(double value) {
  var text = value.toStringAsFixed(6);
  text = text.replaceAll(RegExp(r'0+$'), '');
  text = text.replaceAll(RegExp(r'\.$'), '');
  if (text == '-0') return '0';
  return text;
}

class _Rational {
  final int n;
  final int d;
  const _Rational(this.n, this.d);
}
