import 'expr.dart';
import 'poly.dart';

class CasEquationResult {
  final List<double> solutions;
  final List<double> validSolutions;

  const CasEquationResult({
    required this.solutions,
    required this.validSolutions,
  });
}

class CasSolver {
  CasEquationResult solvePolynomial(Poly poly) {
    final a = poly.a;
    final b = poly.b;
    final c = poly.c;
    if (a.abs() < 1e-9) {
      if (b.abs() < 1e-9) {
        return const CasEquationResult(solutions: <double>[], validSolutions: <double>[]);
      }
      final x = -c / b;
      return CasEquationResult(solutions: [x], validSolutions: [x]);
    }
    final delta = b * b - 4 * a * c;
    if (delta < 0) {
      return const CasEquationResult(solutions: <double>[], validSolutions: <double>[]);
    }
    final sqrt = delta == 0 ? 0.0 : (delta).sqrt();
    final denom = 2 * a;
    final x1 = (-b - sqrt) / denom;
    final x2 = (-b + sqrt) / denom;
    if (delta == 0) {
      return CasEquationResult(solutions: [x1], validSolutions: [x1]);
    }
    return CasEquationResult(solutions: [x1, x2], validSolutions: [x1, x2]);
  }

  CasEquationResult solveAndValidate(
    Expr originalLeft,
    Expr originalRight,
    Poly poly,
  ) {
    final raw = solvePolynomial(poly);
    final filtered = raw.solutions.where((x) {
      final left = originalLeft.eval({'x': x});
      final right = originalRight.eval({'x': x});
      if (left == null || right == null) return false;
      return (left - right).abs() < 1e-6;
    }).toList();
    return CasEquationResult(solutions: raw.solutions, validSolutions: filtered);
  }
}

extension on double {
  double sqrt() {
    if (this < 0) return double.nan;
    if (this == 0) return 0;
    var x = this;
    for (var i = 0; i < 12; i++) {
      x = 0.5 * (x + this / x);
    }
    return x;
  }
}
