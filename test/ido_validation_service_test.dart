import 'package:flutter_test/flutter_test.dart';
import 'package:tessera/features/solver/domain/entities/math_solution.dart';
import 'package:tessera/features/solver/domain/entities/solution_step.dart';
import 'package:tessera/features/solver/domain/services/ido_validation_service.dart';

void main() {
  test('IDO validation fails when outputs do not chain', () {
    final solution = MathSolution(
      problemLatex: '2x + 4 = 10',
      steps: const [
        SolutionStep(
          inputLatex: '2x + 4 = 10',
          description: 'Deplacer un terme de l\'autre cote.',
          outputLatex: '2x = 6',
        ),
        SolutionStep(
          inputLatex: '2x = 7',
          description: 'Diviser les deux cotes par le meme nombre.',
          outputLatex: 'x = 3',
        ),
      ],
      finalAnswerLatex: 'x = 3',
    );

    final validator = IdoValidationService();
    final result = validator.validate(solution);

    expect(result.isValid, isFalse);
    expect(result.issues.isNotEmpty, isTrue);
  });
}
