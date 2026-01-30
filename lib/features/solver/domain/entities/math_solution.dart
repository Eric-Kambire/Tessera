import 'package:freezed_annotation/freezed_annotation.dart';
import 'solution_step.dart';

part 'math_solution.freezed.dart';

@freezed
class MathSolution with _$MathSolution {
  const factory MathSolution({
    required String problemLatex,
    required List<SolutionStep> steps,
    required String finalAnswerLatex,
  }) = _MathSolution;
}
