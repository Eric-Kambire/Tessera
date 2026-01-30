import 'package:injectable/injectable.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/math_solution.dart';
import '../repositories/solver_repository.dart';

@injectable
class SolveEquationUseCase extends UseCase<MathSolution, SolveEquationParams> {
  final SolverRepository repository;

  const SolveEquationUseCase(this.repository);

  @override
  Future<MathSolution> call(SolveEquationParams params) {
    return repository.solveLatex(params.latexInput);
  }
}

class SolveEquationParams {
  final String latexInput;

  const SolveEquationParams(this.latexInput);
}
