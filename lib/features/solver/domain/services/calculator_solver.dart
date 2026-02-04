import '../../../../core/cas/parser.dart';
import '../../../../core/cas/simplifier.dart';
import '../../../../core/utils/latex_input_formatter.dart';
import '../../../../core/utils/math_input_normalizer.dart';
import '../../../../core/utils/rational_formatter.dart';
import '../entities/math_solution.dart';

class CalculatorSolver {
  final CasParser _parser = CasParser();
  final CasSimplifier _simplifier = CasSimplifier();

  MathSolution? trySolve(String rawInput) {
    final normalized = normalizeForEngine(rawInput).replaceAll(' ', '');
    if (_hasRelation(normalized)) return null;

    try {
      final expr = _simplifier.simplify(_parser.parse(normalized));
      final value = expr.eval({});
      if (value == null) return null;

      return MathSolution(
        problemLatex: latexFromRaw(rawInput),
        steps: const [],
        finalAnswerLatex: formatValueFractionFirst(value),
      );
    } catch (_) {
      return null;
    }
  }

  bool _hasRelation(String input) {
    return input.contains('=') ||
        input.contains('<=') ||
        input.contains('>=') ||
        input.contains('<') ||
        input.contains('>');
  }
}
