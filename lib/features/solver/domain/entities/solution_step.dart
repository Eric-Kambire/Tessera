import 'package:freezed_annotation/freezed_annotation.dart';

part 'solution_step.freezed.dart';

@freezed
class SolutionStep with _$SolutionStep {
  const factory SolutionStep({
    required String inputLatex,
    required String description,
    required String outputLatex,
    @Default(false) bool isSubstep,
    @Default(<SolutionStep>[]) List<SolutionStep> subSteps,
  }) = _SolutionStep;
}
