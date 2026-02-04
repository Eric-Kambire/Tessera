import 'package:flutter_test/flutter_test.dart';
import 'package:tessera/features/solver/domain/services/trig_equation_solver.dart';

void main() {
  test('Solves basic trig equations', () {
    final solution = TrigEquationSolver.trySolve('sin(x)=0');
    expect(solution, isNotNull);
    expect(solution!.finalAnswerLatex, contains(r'k\pi'));
  });
}
