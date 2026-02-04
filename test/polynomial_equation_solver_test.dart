import 'package:flutter_test/flutter_test.dart';
import 'package:tessera/features/solver/domain/services/polynomial_equation_solver.dart';

void main() {
  test('Solves factored polynomial equations', () {
    final solution = PolynomialEquationSolver.trySolve('(x-2)(x+3)=0');
    expect(solution, isNotNull);
    expect(solution!.finalAnswerLatex, contains('x_1'));
    expect(solution.finalAnswerLatex, contains('2'));
    expect(solution.finalAnswerLatex, contains('-3'));
  });
}
