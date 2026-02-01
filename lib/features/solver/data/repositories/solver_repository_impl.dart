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
import '../../../../core/errors/failures.dart';
import '../datasources/math_engine_service.dart';
import '../../../../core/utils/math_input_normalizer.dart';
import '../../domain/services/quadratic_solver.dart';
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
  Future<MathSolution> solveLatex(String latex) async {
    final normalized = normalizeForEngine(latex);
    final identity = RemarkableIdentitySolver.trySolve(latex);
    if (identity != null) {
      return identity;
    }
    final fraction = FractionSolver.trySolve(latex);
    if (fraction != null) {
      return fraction;
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
}
