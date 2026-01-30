import '../../domain/entities/math_solution.dart';
import 'solution_step_model.dart';

class MathSolutionModel {
  final String problemLatex;
  final List<SolutionStepModel> steps;
  final String finalAnswerLatex;

  const MathSolutionModel({
    required this.problemLatex,
    required this.steps,
    required this.finalAnswerLatex,
  });

  factory MathSolutionModel.fromJson(Map<String, dynamic> json) {
    final stepsJson = (json['steps'] as List<dynamic>? ?? <dynamic>[])
        .cast<Map<String, dynamic>>();
    return MathSolutionModel(
      problemLatex: json['problem_latex'] as String? ?? '',
      steps: stepsJson.map(SolutionStepModel.fromJson).toList(),
      finalAnswerLatex: json['final_answer'] as String? ?? '',
    );
  }

  MathSolution toEntity() {
    return MathSolution(
      problemLatex: problemLatex,
      steps: steps.map((e) => e.toEntity()).toList(),
      finalAnswerLatex: finalAnswerLatex,
    );
  }
}
