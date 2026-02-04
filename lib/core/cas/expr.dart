import 'dart:math' as math;
import 'poly.dart';

abstract class Expr {
  const Expr();

  String toLatex();
  bool containsSqrt();
  int sqrtCount();
  double? eval(Map<String, double> scope);
  Poly? toPoly();
}

class Num extends Expr {
  final double value;
  const Num(this.value);

  @override
  String toLatex() => _fmt(value);

  @override
  bool containsSqrt() => false;

  @override
  int sqrtCount() => 0;

  @override
  double? eval(Map<String, double> scope) => value;

  @override
  Poly? toPoly() => Poly.constant(value);
}

class Var extends Expr {
  final String name;
  const Var(this.name);

  @override
  String toLatex() => name;

  @override
  bool containsSqrt() => false;

  @override
  int sqrtCount() => 0;

  @override
  double? eval(Map<String, double> scope) => scope[name];

  @override
  Poly? toPoly() => name == 'x' ? Poly.linear(1, 0) : null;
}

class Neg extends Expr {
  final Expr value;
  const Neg(this.value);

  @override
  String toLatex() => '-${_wrapNeg(value)}';

  @override
  bool containsSqrt() => value.containsSqrt();

  @override
  int sqrtCount() => value.sqrtCount();

  @override
  double? eval(Map<String, double> scope) {
    final v = value.eval(scope);
    if (v == null) return null;
    return -v;
  }

  @override
  Poly? toPoly() {
    final p = value.toPoly();
    if (p == null) return null;
    return p * Poly.constant(-1);
  }
}

class Func extends Expr {
  final String name;
  final Expr arg;

  const Func(this.name, this.arg);

  @override
  String toLatex() {
    switch (name) {
      case 'sqrt':
        return r'\sqrt{' + arg.toLatex() + '}';
      case 'sin':
        return r'\sin(' + arg.toLatex() + ')';
      case 'cos':
        return r'\cos(' + arg.toLatex() + ')';
      case 'tan':
        return r'\tan(' + arg.toLatex() + ')';
      case 'log':
        return r'\log(' + arg.toLatex() + ')';
      case 'ln':
        return r'\ln(' + arg.toLatex() + ')';
      default:
        return '$name(' + arg.toLatex() + ')';
    }
  }

  @override
  bool containsSqrt() => name == 'sqrt' || arg.containsSqrt();

  @override
  int sqrtCount() => (name == 'sqrt' ? 1 : 0) + arg.sqrtCount();

  @override
  double? eval(Map<String, double> scope) {
    final v = arg.eval(scope);
    if (v == null) return null;
    switch (name) {
      case 'sqrt':
        if (v < 0) return null;
        return math.sqrt(v);
      case 'sin':
        return math.sin(v);
      case 'cos':
        return math.cos(v);
      case 'tan':
        return math.tan(v);
      case 'log':
        if (v <= 0) return null;
        return math.log(v) / math.ln10;
      case 'ln':
        if (v <= 0) return null;
        return math.log(v);
    }
    return null;
  }

  @override
  Poly? toPoly() => null;
}

class Const extends Expr {
  final String symbol;
  final double value;

  const Const(this.symbol, this.value);

  @override
  String toLatex() => symbol == 'pi' ? r'\pi' : symbol;

  @override
  bool containsSqrt() => false;

  @override
  int sqrtCount() => 0;

  @override
  double? eval(Map<String, double> scope) => value;

  @override
  Poly? toPoly() => Poly.constant(value);
}

class Sin extends Expr {
  final Expr arg;
  const Sin(this.arg);

  @override
  String toLatex() => Func('sin', arg).toLatex();

  @override
  bool containsSqrt() => arg.containsSqrt();

  @override
  int sqrtCount() => arg.sqrtCount();

  @override
  double? eval(Map<String, double> scope) => Func('sin', arg).eval(scope);

  @override
  Poly? toPoly() => null;
}

class Cos extends Expr {
  final Expr arg;
  const Cos(this.arg);

  @override
  String toLatex() => Func('cos', arg).toLatex();

  @override
  bool containsSqrt() => arg.containsSqrt();

  @override
  int sqrtCount() => arg.sqrtCount();

  @override
  double? eval(Map<String, double> scope) => Func('cos', arg).eval(scope);

  @override
  Poly? toPoly() => null;
}

class Tan extends Expr {
  final Expr arg;
  const Tan(this.arg);

  @override
  String toLatex() => Func('tan', arg).toLatex();

  @override
  bool containsSqrt() => arg.containsSqrt();

  @override
  int sqrtCount() => arg.sqrtCount();

  @override
  double? eval(Map<String, double> scope) => Func('tan', arg).eval(scope);

  @override
  Poly? toPoly() => null;
}

class Log extends Expr {
  final Expr arg;
  const Log(this.arg);

  @override
  String toLatex() => Func('log', arg).toLatex();

  @override
  bool containsSqrt() => arg.containsSqrt();

  @override
  int sqrtCount() => arg.sqrtCount();

  @override
  double? eval(Map<String, double> scope) => Func('log', arg).eval(scope);

  @override
  Poly? toPoly() => null;
}

class Ln extends Expr {
  final Expr arg;
  const Ln(this.arg);

  @override
  String toLatex() => Func('ln', arg).toLatex();

  @override
  bool containsSqrt() => arg.containsSqrt();

  @override
  int sqrtCount() => arg.sqrtCount();

  @override
  double? eval(Map<String, double> scope) => Func('ln', arg).eval(scope);

  @override
  Poly? toPoly() => null;
}

class Add extends Expr {
  final Expr left;
  final Expr right;
  const Add(this.left, this.right);

  @override
  String toLatex() => '${left.toLatex()} + ${right.toLatex()}';

  @override
  bool containsSqrt() => left.containsSqrt() || right.containsSqrt();

  @override
  int sqrtCount() => left.sqrtCount() + right.sqrtCount();

  @override
  double? eval(Map<String, double> scope) {
    final l = left.eval(scope);
    final r = right.eval(scope);
    if (l == null || r == null) return null;
    return l + r;
  }

  @override
  Poly? toPoly() {
    final l = left.toPoly();
    final r = right.toPoly();
    if (l == null || r == null) return null;
    return l + r;
  }
}

class Sub extends Expr {
  final Expr left;
  final Expr right;
  const Sub(this.left, this.right);

  @override
  String toLatex() => '${left.toLatex()} - ${right.toLatex()}';

  @override
  bool containsSqrt() => left.containsSqrt() || right.containsSqrt();

  @override
  int sqrtCount() => left.sqrtCount() + right.sqrtCount();

  @override
  double? eval(Map<String, double> scope) {
    final l = left.eval(scope);
    final r = right.eval(scope);
    if (l == null || r == null) return null;
    return l - r;
  }

  @override
  Poly? toPoly() {
    final l = left.toPoly();
    final r = right.toPoly();
    if (l == null || r == null) return null;
    return l - r;
  }
}

class Mul extends Expr {
  final Expr left;
  final Expr right;
  const Mul(this.left, this.right);

  @override
  String toLatex() {
    final l = _wrapMul(left);
    final r = _wrapMul(right);
    return '$l \\cdot $r';
  }

  @override
  bool containsSqrt() => left.containsSqrt() || right.containsSqrt();

  @override
  int sqrtCount() => left.sqrtCount() + right.sqrtCount();

  @override
  double? eval(Map<String, double> scope) {
    final l = left.eval(scope);
    final r = right.eval(scope);
    if (l == null || r == null) return null;
    return l * r;
  }

  @override
  Poly? toPoly() {
    final l = left.toPoly();
    final r = right.toPoly();
    if (l == null || r == null) return null;
    if (l.degree + r.degree > 2) return null;
    return l * r;
  }
}

class Div extends Expr {
  final Expr left;
  final Expr right;
  const Div(this.left, this.right);

  @override
  String toLatex() => r'\frac{' + left.toLatex() + '}{' + right.toLatex() + '}';

  @override
  bool containsSqrt() => left.containsSqrt() || right.containsSqrt();

  @override
  int sqrtCount() => left.sqrtCount() + right.sqrtCount();

  @override
  double? eval(Map<String, double> scope) {
    final l = left.eval(scope);
    final r = right.eval(scope);
    if (l == null || r == null || r.abs() < 1e-12) return null;
    return l / r;
  }

  @override
  Poly? toPoly() {
    final l = left.toPoly();
    final r = right.toPoly();
    if (l == null || r == null) return null;
    if (!r.isConstant) return null;
    if (r.constant.abs() < 1e-12) return null;
    return l / r.constant;
  }
}

class Pow extends Expr {
  final Expr base;
  final Expr exp;
  const Pow(this.base, this.exp);

  @override
  String toLatex() => '${_wrapPow(base)}^{${exp.toLatex()}}';

  @override
  bool containsSqrt() => base.containsSqrt() || exp.containsSqrt();

  @override
  int sqrtCount() => base.sqrtCount() + exp.sqrtCount();

  @override
  double? eval(Map<String, double> scope) {
    final b = base.eval(scope);
    final e = exp.eval(scope);
    if (b == null || e == null) return null;
    return math.pow(b, e).toDouble();
  }

  @override
  Poly? toPoly() {
    final b = base.toPoly();
    if (b == null) return null;
    if (exp is Num) {
      final e = (exp as Num).value;
      if ((e - 0).abs() < 1e-9) return Poly.constant(1);
      if ((e - 1).abs() < 1e-9) return b;
      if ((e - 2).abs() < 1e-9) return b * b;
    }
    return null;
  }
}

class Sqrt extends Expr {
  final Expr radicand;
  const Sqrt(this.radicand);

  @override
  String toLatex() => Func('sqrt', radicand).toLatex();

  @override
  bool containsSqrt() => true;

  @override
  int sqrtCount() => 1 + radicand.sqrtCount();

  @override
  double? eval(Map<String, double> scope) => Func('sqrt', radicand).eval(scope);

  @override
  Poly? toPoly() => null;
}

String _wrapMul(Expr expr) {
  if (expr is Add || expr is Sub) {
    return '(${expr.toLatex()})';
  }
  return expr.toLatex();
}

String _wrapPow(Expr expr) {
  if (expr is Add || expr is Sub || expr is Mul || expr is Div) {
    return '(${expr.toLatex()})';
  }
  return expr.toLatex();
}

String _wrapNeg(Expr expr) {
  if (expr is Add || expr is Sub) {
    return '(${expr.toLatex()})';
  }
  return expr.toLatex();
}

String _fmt(double value) {
  var text = value.toStringAsFixed(6);
  text = text.replaceAll(RegExp(r'0+$'), '');
  text = text.replaceAll(RegExp(r'\.$'), '');
  if (text == '-0') return '0';
  return text;
}
