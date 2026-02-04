import 'package:flutter_test/flutter_test.dart';
import 'package:tessera/features/solver/domain/services/cas_equation_solver.dart';

void main() {
  test('Solves polynomial equation via CAS', () {
    final solution = CasEquationSolver().trySolve('x^2-5x+6=0');
    expect(solution, isNotNull);
    expect(solution!.finalAnswerLatex, contains('x_1'));
    expect(solution.finalAnswerLatex, contains('2'));
    expect(solution.finalAnswerLatex, contains('3'));
  });

  test('Solves simple radical equation', () {
    final solution = CasEquationSolver().trySolve('sqrt(x+1)=3');
    expect(solution, isNotNull);
    expect(solution!.finalAnswerLatex, contains('8'));
  });

  test('Solves double radical equation', () {
    final solution = CasEquationSolver().trySolve('sqrt(x+1)+sqrt(x-2)=5');
    expect(solution, isNotNull);
    expect(solution!.finalAnswerLatex, isNot(contains('Aucune')));
  });

  test('Solves trig equation inside CAS', () {
    final solution = CasEquationSolver().trySolve('sin(x)=0');
    expect(solution, isNotNull);
    expect(solution!.finalAnswerLatex, contains(r'k\pi'));
  });

  test('Solves log equation inside CAS', () {
    final solution = CasEquationSolver().trySolve('ln(x)=0');
    expect(solution, isNotNull);
    expect(solution!.finalAnswerLatex, contains('1'));
  });

  test('Solves quadratic inequality', () {
    final solution = CasEquationSolver().trySolve('x^2-4<=0');
    expect(solution, isNotNull);
    expect(solution!.finalAnswerLatex, contains('[-2'));
    expect(solution.finalAnswerLatex, contains('2]'));
  });

  test('Solves mixed radical-linear equation', () {
    final solution = CasEquationSolver().trySolve('x*sqrt(x)-2x=0');
    expect(solution, isNotNull);
    expect(solution!.finalAnswerLatex, contains('x = 0'));
    expect(solution.finalAnswerLatex, contains('4'));
  });

  test('Solves linear equation with radicals and rationalizes', () {
    final solution = CasEquationSolver().trySolve('3*sqrt(3)*x+2=x+sqrt(3)');
    expect(solution, isNotNull);
    expect(solution!.finalAnswerLatex, contains('\\sqrt{3}'));
  });
}
