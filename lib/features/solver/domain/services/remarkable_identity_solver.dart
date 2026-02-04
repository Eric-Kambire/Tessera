import '../../../../core/utils/latex_input_formatter.dart';
import '../entities/math_solution.dart';
import '../entities/solution_step.dart';

class RemarkableIdentitySolver {
  static MathSolution? trySolve(String rawInput) {
    final trimmed = rawInput.replaceAll(' ', '');
    if (trimmed.contains('=')) return null;

    final expanded = _expandIdentity(trimmed);
    if (expanded == null) return null;

    final problemLatex = latexFromRaw(rawInput);
    final expandedLatex = latexFromRaw(expanded);

    final steps = <SolutionStep>[
      SolutionStep(
        inputLatex: problemLatex,
        description: 'Reconnaître une identité remarquable.',
        outputLatex: expandedLatex,
      ),
    ];

    return MathSolution(
      problemLatex: problemLatex,
      steps: steps,
      finalAnswerLatex: expandedLatex,
    );
  }

  static String? _expandIdentity(String input) {
    final squareMatch = RegExp(r'^\(([^()]+)\)\^2$').firstMatch(input);
    if (squareMatch != null) {
      final inside = squareMatch.group(1) ?? '';
      final split = _splitTopLevel(inside);
      if (split == null) return null;
      final a = split.a;
      final b = split.b;
      if (split.op == '+') {
        return '${a}^2+2*${a}*${b}+${b}^2';
      }
      if (split.op == '-') {
        return '${a}^2-2*${a}*${b}+${b}^2';
      }
    }

    final prodMatch = RegExp(r'^\(([^()]+)\)\(([^()]+)\)$').firstMatch(input);
    if (prodMatch != null) {
      final left = prodMatch.group(1) ?? '';
      final right = prodMatch.group(2) ?? '';
      final leftSplit = _splitTopLevel(left);
      final rightSplit = _splitTopLevel(right);
      if (leftSplit == null || rightSplit == null) return null;

      final a1 = leftSplit.a;
      final b1 = leftSplit.b;
      final a2 = rightSplit.a;
      final b2 = rightSplit.b;

      final isConjugate = leftSplit.op != rightSplit.op && a1 == a2 && b1 == b2;
      if (isConjugate) {
        return '${a1}^2-${b1}^2';
      }
    }

    return null;
  }
}

class _SplitResult {
  final String a;
  final String b;
  final String op;

  const _SplitResult(this.a, this.b, this.op);
}

_SplitResult? _splitTopLevel(String input) {
  var depth = 0;
  for (var i = 0; i < input.length; i++) {
    final ch = input[i];
    if (ch == '(') depth++;
    if (ch == ')') depth--;
    if (depth == 0 && (ch == '+' || ch == '-')) {
      final left = input.substring(0, i);
      final right = input.substring(i + 1);
      if (left.isEmpty || right.isEmpty) return null;
      return _SplitResult(left, right, ch);
    }
  }
  return null;
}
