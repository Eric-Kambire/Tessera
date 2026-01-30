import 'engine_step_model.dart';

class EngineSolutionModel {
  final String problemLatex;
  final List<EngineStepModel> steps;
  final String finalAnswer;

  const EngineSolutionModel({
    required this.problemLatex,
    required this.steps,
    required this.finalAnswer,
  });

  factory EngineSolutionModel.fromJson(Map<String, dynamic> json) {
    final stepsJson = (json['steps'] as List<dynamic>? ?? <dynamic>[]) 
        .whereType<Map<String, dynamic>>()
        .toList();

    return EngineSolutionModel(
      problemLatex: json['problem_latex'] as String? ?? json['problemLatex'] as String? ?? '',
      steps: stepsJson.map(EngineStepModel.fromJson).toList(),
      finalAnswer: json['final_answer'] as String? ?? json['finalAnswer'] as String? ?? '',
    );
  }
}
