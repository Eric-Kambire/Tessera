import '../../../../core/utils/latex_input_formatter.dart';
import '../../../../core/utils/math_input_normalizer.dart';
import '../entities/math_solution.dart';
import '../entities/solution_step.dart';

class TrigEquationSolver {
  static MathSolution? trySolve(String rawInput) {
    final normalized = normalizeForEngine(rawInput).replaceAll(' ', '');
    if (!normalized.contains('=')) return null;
    final parts = normalized.split('=');
    if (parts.length != 2) return null;

    final left = parts[0];
    final right = parts[1];

    final leftTrig = _parseTrig(left);
    final rightTrig = _parseTrig(right);

    if (leftTrig == null && rightTrig == null) return null;

    if (leftTrig != null && rightTrig == null) {
      return _solveTrig(leftTrig, right, rawInput);
    }
    if (rightTrig != null && leftTrig == null) {
      return _solveTrig(rightTrig, left, rawInput);
    }

    if (leftTrig != null && rightTrig != null) {
      if (leftTrig.func == 'sin' && rightTrig.func == 'cos' && _isArgX(leftTrig) && _isArgX(rightTrig)) {
        return _solveSinEqualsCos(rawInput);
      }
      return null;
    }

    return null;
  }
}

class _TrigCall {
  final String func;
  final String arg;

  const _TrigCall(this.func, this.arg);
}

_TrigCall? _parseTrig(String input) {
  final match = RegExp(r'^(sin|cos|tan)\(([^()]+)\)$').firstMatch(input);
  if (match == null) return null;
  final func = match.group(1) ?? '';
  final arg = match.group(2) ?? '';
  if (func.isEmpty || arg.isEmpty) return null;
  return _TrigCall(func, arg);
}

bool _isArgX(_TrigCall call) => call.arg == 'x';

MathSolution? _solveTrig(_TrigCall trig, String rawValue, String rawInput) {
  if (!_isArgX(trig)) return null;
  if (_containsVariable(rawValue)) return null;

  final inputLatex = latexFromRaw(rawInput);
  final valueLatex = latexFromRaw(rawValue);
  final eqLatex = '${trig.func}(x) = $valueLatex';

  final steps = <SolutionStep>[
    SolutionStep(
      inputLatex: inputLatex,
      description: 'Identifier l’équation trigonométrique.',
      outputLatex: eqLatex,
    ),
  ];

  final solutionLatex = _generalSolution(trig.func, valueLatex);
  if (solutionLatex == null) return null;

  steps.add(
    SolutionStep(
      inputLatex: eqLatex,
      description: 'Appliquer la solution générale correspondante.',
      outputLatex: solutionLatex,
    ),
  );

  return MathSolution(
    problemLatex: inputLatex,
    steps: steps,
    finalAnswerLatex: solutionLatex,
  );
}

String? _generalSolution(String func, String valueLatex) {
  if (valueLatex == '0') {
    switch (func) {
      case 'sin':
        return r'x = k\pi';
      case 'cos':
        return r'x = \frac{\pi}{2} + k\pi';
      case 'tan':
        return r'x = k\pi';
    }
  }

  switch (func) {
    case 'sin':
      return r'x = (-1)^k\arcsin(' + valueLatex + r') + k\pi';
    case 'cos':
      return r'x = \pm\arccos(' + valueLatex + r') + 2k\pi';
    case 'tan':
      return r'x = \arctan(' + valueLatex + r') + k\pi';
  }
  return null;
}

MathSolution _solveSinEqualsCos(String rawInput) {
  final inputLatex = latexFromRaw(rawInput);
  final steps = <SolutionStep>[
    SolutionStep(
      inputLatex: inputLatex,
      description: 'Utiliser l’égalité sin(x) = cos(x).',
      outputLatex: r'\tan(x) = 1',
    ),
    SolutionStep(
      inputLatex: r'\tan(x) = 1',
      description: 'Appliquer la solution générale de tan(x) = a.',
      outputLatex: r'x = \frac{\pi}{4} + k\pi',
    ),
  ];

  return MathSolution(
    problemLatex: inputLatex,
    steps: steps,
    finalAnswerLatex: r'x = \frac{\pi}{4} + k\pi',
  );
}

bool _containsVariable(String value) {
  var text = value;
  text = text.replaceAll('pi', '');
  text = text.replaceAll('e', '');
  text = text.replaceAll('sqrt', '');
  text = text.replaceAll('cbrt', '');
  return RegExp(r'[a-zA-Z]').hasMatch(text);
}
