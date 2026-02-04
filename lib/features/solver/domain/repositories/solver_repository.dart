import '../entities/math_solution.dart';
import '../entities/solve_method.dart';

abstract class SolverRepository {
  Future<MathSolution> solveLatex(String latex, {SolveMethod? method});
}
