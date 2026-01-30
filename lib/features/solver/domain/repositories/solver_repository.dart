import '../entities/math_solution.dart';

abstract class SolverRepository {
  Future<MathSolution> solveLatex(String latex);
}
