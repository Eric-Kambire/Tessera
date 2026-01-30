import '../../domain/entities/solution_step.dart';

class SolutionStepModel {
  final String inputLatex;
  final String description;
  final String outputLatex;
  final bool isSubstep;

  const SolutionStepModel({
    required this.inputLatex,
    required this.description,
    required this.outputLatex,
    required this.isSubstep,
  });

  factory SolutionStepModel.fromJson(Map<String, dynamic> json) {
    return SolutionStepModel(
      inputLatex: json['input_latex'] as String? ?? '',
      description: json['description'] as String? ?? '',
      outputLatex: json['output_latex'] as String? ?? '',
      isSubstep: json['is_substep'] as bool? ?? false,
    );
  }

  SolutionStep toEntity() {
    return SolutionStep(
      inputLatex: inputLatex,
      description: description,
      outputLatex: outputLatex,
      isSubstep: isSubstep,
    );
  }
}
