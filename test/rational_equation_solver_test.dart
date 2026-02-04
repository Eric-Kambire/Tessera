import 'package:flutter_test/flutter_test.dart';
import 'package:tessera/features/solver/domain/services/rational_equation_solver.dart';

void main() {
  test('Solves rational equations with domain restrictions', () {
    final solution = RationalEquationSolver.trySolve('(x+1)/(x-2)=3');
    expect(solution, isNotNull);
    expect(solution!.finalAnswerLatex, contains('x ='));
    expect(solution.finalAnswerLatex, contains('3.5'));
  });
}
