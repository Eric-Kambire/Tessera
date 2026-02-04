import 'dart:math' as math;
import 'expr.dart';
import 'poly.dart';

class CasSimplifier {
  Expr simplify(Expr expr) {
    if (expr is Num || expr is Var || expr is Const) return expr;
    if (expr is Neg) {
      final inner = simplify(expr.value);
      if (inner is Num) return Num(-inner.value);
      if (inner is Neg) return inner.value;
      return Neg(inner);
    }
    if (expr is Func) return Func(expr.name, simplify(expr.arg));
    if (expr is Sin) return Sin(simplify(expr.arg));
    if (expr is Cos) return Cos(simplify(expr.arg));
    if (expr is Tan) return Tan(simplify(expr.arg));
    if (expr is Log) return Log(simplify(expr.arg));
    if (expr is Ln) return Ln(simplify(expr.arg));
    if (expr is Sqrt) return Sqrt(simplify(expr.radicand));
    if (expr is Add) return _simplifyAdd(expr);
    if (expr is Sub) return _simplifySub(expr);
    if (expr is Mul) return _simplifyMul(expr);
    if (expr is Div) return _simplifyDiv(expr);
    if (expr is Pow) return _simplifyPow(expr);
    return expr;
  }

  Expr _simplifyAdd(Add expr) {
    final l = simplify(expr.left);
    final r = simplify(expr.right);
    if (l is Num && r is Num) return Num(l.value + r.value);
    final poly = Add(l, r).toPoly();
    if (poly != null) return _polyToExpr(poly);
    final polyN = _PolyN.fromExpr(Add(l, r));
    if (polyN != null) return _polyNToExpr(polyN);
    return Add(l, r);
  }

  Expr _simplifySub(Sub expr) {
    final l = simplify(expr.left);
    final r = simplify(expr.right);
    if (l is Num && r is Num) return Num(l.value - r.value);
    final poly = Sub(l, r).toPoly();
    if (poly != null) return _polyToExpr(poly);
    final polyN = _PolyN.fromExpr(Sub(l, r));
    if (polyN != null) return _polyNToExpr(polyN);
    return Sub(l, r);
  }

  Expr _simplifyMul(Mul expr) {
    final l = simplify(expr.left);
    final r = simplify(expr.right);
    if (l is Num && r is Num) return Num(l.value * r.value);
    if (l is Num && l.value == 0) return const Num(0);
    if (r is Num && r.value == 0) return const Num(0);
    if (l is Num && l.value == 1) return r;
    if (r is Num && r.value == 1) return l;
    final poly = Mul(l, r).toPoly();
    if (poly != null) return _polyToExpr(poly);
    final polyN = _PolyN.fromExpr(Mul(l, r));
    if (polyN != null) return _polyNToExpr(polyN);
    return Mul(l, r);
  }

  Expr _simplifyDiv(Div expr) {
    final l = simplify(expr.left);
    final r = simplify(expr.right);
    if (l is Num && r is Num && r.value != 0) return Num(l.value / r.value);
    if (r is Num && r.value == 1) return l;
    return Div(l, r);
  }

  Expr _simplifyPow(Pow expr) {
    final b = simplify(expr.base);
    final e = simplify(expr.exp);
    if (e is Num && b is Num) return Num(math.pow(b.value, e.value).toDouble());
    if (e is Num && (e.value - 1).abs() < 1e-9) return b;
    if (e is Num && (e.value - 0).abs() < 1e-9) return const Num(1);
    if (e is Num && e.value % 1 == 0) {
      final power = e.value.toInt();
      if (power >= 2 && power <= 4) {
        final basePoly = _PolyN.fromExpr(b);
        if (basePoly != null) {
          var result = basePoly;
          for (var i = 1; i < power; i++) {
            final next = result.mul(basePoly);
            if (next == null) {
              result = result;
              break;
            }
            result = next;
          }
          return _polyNToExpr(result);
        }
      }
    }
    return Pow(b, e);
  }

  Expr _polyToExpr(Poly poly) {
    final a = poly.a;
    final b = poly.b;
    final c = poly.c;
    Expr? current;
    if (a.abs() >= 1e-9) {
      final term = Mul(Num(a), Pow(const Var('x'), const Num(2)));
      current = term;
    }
    if (b.abs() >= 1e-9) {
      final term = Mul(Num(b), const Var('x'));
      current = current == null ? term : Add(current, term);
    }
    if (c.abs() >= 1e-9) {
      final term = Num(c);
      current = current == null ? term : Add(current, term);
    }
    return current ?? const Num(0);
  }

  Expr _polyNToExpr(_PolyN poly) {
    Expr? current;
    for (var degree = poly.maxDegree; degree >= 0; degree--) {
      final coeff = poly.coeffAt(degree);
      if (coeff.abs() < 1e-9) continue;
      final term = _termFor(coeff, degree);
      current = current == null ? term : Add(current, term);
    }
    return current ?? const Num(0);
  }

  Expr _termFor(double coeff, int degree) {
    if (degree == 0) return Num(coeff);
    Expr base = const Var('x');
    if (degree > 1) {
      base = Pow(const Var('x'), Num(degree.toDouble()));
    }
    if ((coeff - 1).abs() < 1e-9) return base;
    if ((coeff + 1).abs() < 1e-9) return Mul(const Num(-1), base);
    return Mul(Num(coeff), base);
  }
}

class _PolyN {
  final List<double> coeffs;
  final int maxDegree;

  const _PolyN(this.coeffs, this.maxDegree);

  double coeffAt(int degree) => degree < coeffs.length ? coeffs[degree] : 0;

  _PolyN add(_PolyN other) {
    final size = math.max(coeffs.length, other.coeffs.length);
    final res = List<double>.filled(size, 0);
    for (var i = 0; i < size; i++) {
      res[i] = (i < coeffs.length ? coeffs[i] : 0) + (i < other.coeffs.length ? other.coeffs[i] : 0);
    }
    return _PolyN(res, math.max(maxDegree, other.maxDegree));
  }

  _PolyN sub(_PolyN other) {
    final size = math.max(coeffs.length, other.coeffs.length);
    final res = List<double>.filled(size, 0);
    for (var i = 0; i < size; i++) {
      res[i] = (i < coeffs.length ? coeffs[i] : 0) - (i < other.coeffs.length ? other.coeffs[i] : 0);
    }
    return _PolyN(res, math.max(maxDegree, other.maxDegree));
  }

  _PolyN? mul(_PolyN other) {
    final deg = maxDegree + other.maxDegree;
    if (deg > 4) return null;
    final res = List<double>.filled(deg + 1, 0);
    for (var i = 0; i <= maxDegree; i++) {
      for (var j = 0; j <= other.maxDegree; j++) {
        res[i + j] += coeffAt(i) * other.coeffAt(j);
      }
    }
    return _PolyN(res, deg);
  }

  static _PolyN? fromExpr(Expr expr) {
    if (expr is Num) {
      return _PolyN([expr.value], 0);
    }
    if (expr is Const) {
      return _PolyN([expr.value], 0);
    }
    if (expr is Var && expr.name == 'x') {
      return _PolyN([0, 1], 1);
    }
    if (expr is Pow && expr.base is Var && (expr.base as Var).name == 'x' && expr.exp is Num) {
      final power = (expr.exp as Num).value;
      if (power % 1 == 0 && power >= 0 && power <= 4) {
        final deg = power.toInt();
        final res = List<double>.filled(deg + 1, 0);
        res[deg] = 1;
        return _PolyN(res, deg);
      }
    }
    if (expr is Add) {
      final l = fromExpr(expr.left);
      final r = fromExpr(expr.right);
      if (l == null || r == null) return null;
      return l.add(r);
    }
    if (expr is Sub) {
      final l = fromExpr(expr.left);
      final r = fromExpr(expr.right);
      if (l == null || r == null) return null;
      return l.sub(r);
    }
    if (expr is Mul) {
      final l = fromExpr(expr.left);
      final r = fromExpr(expr.right);
      if (l == null || r == null) return null;
      return l.mul(r);
    }
    if (expr is Div) {
      final l = fromExpr(expr.left);
      final r = fromExpr(expr.right);
      if (l == null || r == null) return null;
      if (r.maxDegree == 0 && r.coeffAt(0).abs() > 1e-9) {
        final scalar = r.coeffAt(0);
        final res = l.coeffs.map((v) => v / scalar).toList();
        return _PolyN(res, l.maxDegree);
      }
    }
    return null;
  }
}
