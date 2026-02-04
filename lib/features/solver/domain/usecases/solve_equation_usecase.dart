import 'package:injectable/injectable.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/math_solution.dart';
import '../entities/solve_method.dart';
import '../repositories/solver_repository.dart';

@injectable
class SolveEquationUseCase extends UseCase<MathSolution, SolveEquationParams> {
  final SolverRepository repository;

  const SolveEquationUseCase(this.repository);

  @override
  Future<MathSolution> call(SolveEquationParams params) {
    return repository.solveLatex(params.latexInput, method: params.method);
  }
}

class SolveEquationParams {
  final String latexInput;
  final SolveMethod? method;

  const SolveEquationParams(this.latexInput, {this.method});
}
