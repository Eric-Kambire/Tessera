import 'package:injectable/injectable.dart';
import '../entities/math_solution.dart';
import '../entities/solution_step.dart';

class IdoValidationResult {
  final bool isValid;
  final List<String> issues;

  const IdoValidationResult({
    required this.isValid,
    required this.issues,
  });
}

@LazySingleton()
class IdoValidationService {
  IdoValidationResult validate(MathSolution solution) {
    final issues = <String>[];
    _validateList(solution.steps, issues, pathPrefix: 'Step');

    return IdoValidationResult(
      isValid: issues.isEmpty,
      issues: issues,
    );
  }

  void _validateList(
    List<SolutionStep> steps,
    List<String> issues, {
    required String pathPrefix,
  }) {
    for (var i = 0; i < steps.length; i++) {
      final current = steps[i];
      final label = '$pathPrefix ${i + 1}';
      if (!_hasSentencePunctuation(current.description)) {
        issues.add('$label description must be a full sentence.');
      }
      if (!_startsWithUppercase(current.description)) {
        issues.add('$label description must start with a capital letter.');
      }
      if (i < steps.length - 1) {
        final next = steps[i + 1];
        if (current.outputLatex != next.inputLatex) {
          issues.add('$label output does not match ${pathPrefix.toLowerCase()} ${i + 2} input.');
        }
      }
      if (current.subSteps.isNotEmpty) {
        _validateList(current.subSteps, issues, pathPrefix: '$label substep');
      }
    }
  }

  bool _hasSentencePunctuation(String text) {
    return text.trim().endsWith('.');
  }

  bool _startsWithUppercase(String text) {
    final trimmed = text.trimLeft();
    if (trimmed.isEmpty) return false;
    final first = trimmed[0];
    return first.toUpperCase() == first && first.toLowerCase() != first;
  }
}
