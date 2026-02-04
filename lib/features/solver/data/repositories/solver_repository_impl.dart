import 'dart:convert';
import 'package:injectable/injectable.dart';
import '../../domain/entities/math_solution.dart';
import '../../domain/entities/solution_step.dart';
import '../../domain/repositories/solver_repository.dart';
import '../../domain/services/ido_validation_service.dart';
import '../../domain/services/latex_change_highlighter.dart';
import '../../domain/services/step_description_mapper.dart';
import '../../domain/services/remarkable_identity_solver.dart';
import '../../domain/services/fraction_solver.dart';
import '../../domain/services/calculator_solver.dart';
import '../../domain/services/cas_equation_solver.dart';
import '../../domain/services/polynomial_equation_solver.dart';
import '../../domain/services/quadratic_factoring_solver.dart';
import '../../domain/services/quadratic_completing_square_solver.dart';
import '../../domain/services/rational_equation_solver.dart';
import '../../domain/services/trig_equation_solver.dart';
import '../../../../core/errors/failures.dart';
import '../datasources/math_engine_service.dart';
import '../../../../core/utils/math_input_normalizer.dart';
import '../../domain/services/quadratic_solver.dart';
import '../../domain/entities/solve_method.dart';
import '../models/engine_solution_model.dart';
import '../models/engine_step_model.dart';

@LazySingleton(as: SolverRepository)
class SolverRepositoryImpl implements SolverRepository {
  final MathEngineService engine;
  final StepDescriptionMapper descriptionMapper;
  final LatexChangeHighlighter highlighter;
  final IdoValidationService validator;

  const SolverRepositoryImpl(
    this.engine,
    this.descriptionMapper,
    this.highlighter,
    this.validator,
  );

  @override
  Future<MathSolution> solveLatex(String latex, {SolveMethod? method}) async {
    final normalized = normalizeForEngine(latex);
    if (method != null && _looksQuadratic(normalized)) {
      final viaMethod = _solveQuadraticWithMethod(latex, normalized, method);
      if (viaMethod != null) {
        return viaMethod;
      }
    }
    final identity = RemarkableIdentitySolver.trySolve(latex);
    if (identity != null) {
      return identity;
    }
    final fraction = FractionSolver.trySolve(latex);
    if (fraction != null) {
      return fraction;
    }
    final calculator = CalculatorSolver().trySolve(latex);
    if (calculator != null) {
      return calculator;
    }
    if (method == SolveMethod.completingSquare && _looksQuadratic(normalized)) {
      final square = QuadraticCompletingSquareSolver.trySolve(latex, normalized);
      if (square != null) {
        return square;
      }
    }
    final cas = CasEquationSolver().trySolve(latex);
    if (cas != null) {
      return cas;
    }
    final trig = TrigEquationSolver.trySolve(latex);
    if (trig != null) {
      return trig;
    }
    final rational = RationalEquationSolver.trySolve(latex);
    if (rational != null) {
      return rational;
    }
    final polynomial = PolynomialEquationSolver.trySolve(latex);
    if (polynomial != null) {
      return polynomial;
    }
    final factoredQuadratic = QuadraticFactoringSolver.trySolve(latex);
    if (factoredQuadratic != null) {
      return factoredQuadratic;
    }
    final quadratic = QuadraticSolver.trySolve(latex, normalized);
    if (quadratic != null) {
      return quadratic;
    }

    final rawJson = await engine.solveLatex(normalized);
    final Map<String, dynamic> decoded = json.decode(rawJson) as Map<String, dynamic>;
    if (decoded['error'] == true) {
      final message = decoded['message'] as String? ?? 'Erreur de resolution.';
      throw NotSolvableFailure(message);
    }
    final model = EngineSolutionModel.fromJson(decoded);

    final rootSteps = _mapSteps(model.steps, isSubstep: false);
    final solution = MathSolution(
      problemLatex: model.problemLatex.isEmpty ? latex : model.problemLatex,
      steps: rootSteps,
      finalAnswerLatex: model.finalAnswer,
    );

    final validation = validator.validate(solution);
    if (!validation.isValid) {
      // Soft-fail: return solution but allow UI to display it.
    }

    return solution;
  }

  List<SolutionStep> _mapSteps(List<EngineStepModel> steps, {required bool isSubstep}) {
    return steps.map((step) {
      final output = highlighter.apply(step.newExpression, step.changedIndices);
      final subSteps = step.subSteps.isEmpty
          ? const <SolutionStep>[]
          : _mapSteps(step.subSteps, isSubstep: true);
      return SolutionStep(
        inputLatex: step.oldExpression,
        description: descriptionMapper.map(step.changeType),
        outputLatex: output,
        isSubstep: isSubstep,
        subSteps: subSteps,
      );
    }).toList();
  }

  bool _looksQuadratic(String normalized) {
    return normalized.contains('x^2') && normalized.contains('=');
  }

  MathSolution? _solveQuadraticWithMethod(String raw, String normalized, SolveMethod method) {
    switch (method) {
      case SolveMethod.factoring:
        return QuadraticFactoringSolver.trySolve(raw);
      case SolveMethod.completingSquare:
        return QuadraticCompletingSquareSolver.trySolve(raw, normalized);
      case SolveMethod.quadraticFormula:
        return QuadraticSolver.trySolve(raw, normalized);
      case SolveMethod.auto:
        return null;
    }
  }
}
