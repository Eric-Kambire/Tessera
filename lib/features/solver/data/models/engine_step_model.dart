class EngineStepModel {
  final int stepId;
  final String changeType;
  final String oldExpression;
  final String newExpression;
  final List<EngineStepModel> subSteps;
  final bool changeGroup;
  final List<List<int>> changedIndices;

  const EngineStepModel({
    required this.stepId,
    required this.changeType,
    required this.oldExpression,
    required this.newExpression,
    required this.subSteps,
    required this.changeGroup,
    required this.changedIndices,
  });

  factory EngineStepModel.fromJson(Map<String, dynamic> json) {
    final subStepsJson = (json['subSteps'] as List<dynamic>? ?? <dynamic>[])
        .whereType<Map<String, dynamic>>()
        .toList();

    final indices = <List<int>>[];
    final raw = json['changed_indices'] ?? json['changedIndices'];
    if (raw is List) {
      for (final item in raw) {
        if (item is List && item.length >= 2) {
          final start = item[0];
          final end = item[1];
          if (start is int && end is int) {
            indices.add([start, end]);
          }
        }
      }
    }

    return EngineStepModel(
      stepId: json['stepId'] as int? ?? json['step_id'] as int? ?? 0,
      changeType: json['changeType'] as String? ?? json['description_key'] as String? ?? '',
      oldExpression: json['oldExpression'] as String? ?? json['oldNode'] as String? ?? json['input_latex'] as String? ?? '',
      newExpression: json['newExpression'] as String? ?? json['newNode'] as String? ?? json['output_latex'] as String? ?? '',
      subSteps: subStepsJson.map(EngineStepModel.fromJson).toList(),
      changeGroup: json['changeGroup'] as bool? ?? false,
      changedIndices: indices,
    );
  }
}
