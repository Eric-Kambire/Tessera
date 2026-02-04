import 'package:flutter_test/flutter_test.dart';
import 'package:tessera/features/solver/domain/services/quadratic_factoring_solver.dart';

void main() {
  test('Factors and solves simple quadratics', () {
    final solution = QuadraticFactoringSolver.trySolve('x^2-5x+6=0');
    expect(solution, isNotNull);
    expect(solution!.finalAnswerLatex, contains('x_1'));
    expect(solution.finalAnswerLatex, contains('2'));
    expect(solution.finalAnswerLatex, contains('3'));
  });
}
