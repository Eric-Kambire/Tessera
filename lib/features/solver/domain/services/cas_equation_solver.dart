import 'dart:math' as math;
import '../../../../core/cas/expr.dart';
import '../../../../core/cas/parser.dart';
import '../../../../core/cas/poly.dart';
import '../../../../core/cas/solver.dart';
import '../../../../core/cas/simplifier.dart';
import '../../../../core/cas/statement.dart';
import '../../../../core/utils/latex_input_formatter.dart';
import '../../../../core/utils/math_input_normalizer.dart';
import '../entities/math_solution.dart';
import '../entities/solution_step.dart';

class CasEquationSolver {
  final CasParser _parser = CasParser();
  final CasSolver _solver = CasSolver();
  final CasSimplifier _simplifier = CasSimplifier();

  MathSolution? trySolve(String rawInput) {
    var normalized = normalizeForEngine(rawInput).replaceAll(' ', '');
    normalized = normalized.replaceAll('?', '<=').replaceAll('?', '>=');
    if (_containsUnknownIdentifiers(normalized)) return null;

    Expr left;
    Expr right;
    RelOp? relOp;
    try {
      final statement = _parser.parseStatement(normalized);
      if (statement is Equation) {
        left = _simplifier.simplify(statement.left);
        right = _simplifier.simplify(statement.right);
        relOp = RelOp.eq;
      } else if (statement is Inequality) {
        left = _simplifier.simplify(statement.left);
        right = _simplifier.simplify(statement.right);
        relOp = statement.op;
      } else {
        return null;
      }
    } catch (_) {
      return null;
    }

    if (relOp != null && relOp != RelOp.eq) {
      return _solveInequalityAst(rawInput, relOp!, left, right, _simplifier);
    }

    final inputLatex = latexFromRaw(rawInput);
    final steps = <SolutionStep>[];

    final totalSqrt = left.sqrtCount() + right.sqrtCount();
    if (totalSqrt > 0) {
      final radical = _solveRadical(left, right, steps, inputLatex);
      if (radical != null) return radical;
      final radicalLinear = _solveRadicalProductLinear(left, right, inputLatex);
      if (radicalLinear != null) return radicalLinear;
      return null;
    }

    final trig = _solveTrigEquation(left, right, inputLatex);
    if (trig != null) return trig;

    final logEq = _solveLogEquation(left, right, inputLatex);
    if (logEq != null) return logEq;

    final linearSymbolic = _solveLinearSymbolic(left, right, inputLatex);
    if (linearSymbolic != null) return linearSymbolic;

    final poly = _simplifier.simplify(Sub(left, right)).toPoly();
    if (poly == null) return null;

    final standard = _equationLatex(Sub(left, right), Num(0));
    steps.add(
      SolutionStep(
        inputLatex: inputLatex,
        description: 'Ramener l’équation à la forme f(x) = 0.',
        outputLatex: standard,
      ),
    );

    final result = _solver.solveAndValidate(left, right, poly);
    steps.add(
      SolutionStep(
        inputLatex: standard,
        description: 'Résoudre l’équation polynomiale associée.',
        outputLatex: _solutionLatex(result.solutions),
      ),
    );

    return MathSolution(
      problemLatex: inputLatex,
      steps: steps,
      finalAnswerLatex: _solutionLatex(result.validSolutions),
    );
  }

  MathSolution? _solveRadical(
    Expr left,
    Expr right,
    List<SolutionStep> steps,
    String inputLatex,
  ) {
    final single = _solveSingleRadical(left, right, steps, inputLatex);
    if (single != null) return single;
    final total = left.sqrtCount() + right.sqrtCount();
    if (total >= 2) {
      return _solveDoubleRadical(left, right, steps, inputLatex);
    }
    return null;
  }

  MathSolution? _solveSingleRadical(
    Expr left,
    Expr right,
    List<SolutionStep> steps,
    String inputLatex,
  ) {
    final isolate = _isolateSingleSqrt(left, right);
    if (isolate == null) return null;

    final sqrtExpr = isolate.sqrtExpr;
    final otherSide = isolate.otherSide;

    steps.add(
      SolutionStep(
        inputLatex: inputLatex,
        description: 'Isoler l’expression radicale.',
        outputLatex: _equationLatex(sqrtExpr, otherSide),
      ),
    );

    final sqrtArg = _sqrtArg(sqrtExpr);
    final squaredLeft = sqrtArg ?? Pow(sqrtExpr, const Num(2));
    final squaredRight = Pow(otherSide, const Num(2));
    steps.add(
      SolutionStep(
        inputLatex: _equationLatex(sqrtExpr, otherSide),
        description: 'Élever les deux membres au carré pour éliminer la racine.',
        outputLatex: _equationLatex(squaredLeft, squaredRight),
      ),
    );

    final standardExpr = _simplifier.simplify(Sub(squaredLeft, squaredRight));
    final standard = _equationLatex(standardExpr, const Num(0));
    final poly = standardExpr.toPoly();
    if (poly == null) {
      final higher = _solveHigherDegreePolynomial(standardExpr, left, right, domainMin: 0);
      if (higher == null) return null;
      steps.add(
        SolutionStep(
          inputLatex: _equationLatex(squaredLeft, squaredRight),
          description: 'Ramener ? la forme f(x) = 0.',
          outputLatex: standard,
        ),
      );
      steps.add(
        SolutionStep(
          inputLatex: standard,
          description: 'R?soudre num?riquement l??quation polynomiale obtenue.',
          outputLatex: _solutionLatex(higher.solutions),
        ),
      );
      if (higher.validSolutions.length != higher.solutions.length) {
        steps.add(
          SolutionStep(
            inputLatex: _solutionLatex(higher.solutions),
            description: 'V?rifier les solutions dans l??quation initiale afin d??carter les solutions extrins?ques.',
            outputLatex: _solutionLatex(higher.validSolutions),
          ),
        );
      }
      return MathSolution(
        problemLatex: inputLatex,
        steps: steps,
        finalAnswerLatex: _solutionLatex(higher.validSolutions),
      );
    }

    steps.add(
      SolutionStep(
        inputLatex: _equationLatex(squaredLeft, squaredRight),
        description: 'Ramener ? la forme f(x) = 0.',
        outputLatex: standard,
      ),
    );

    final result = _solver.solveAndValidate(left, right, poly);
    steps.add(
      SolutionStep(
        inputLatex: standard,
        description: 'Résoudre l’équation algébrique obtenue.',
        outputLatex: _solutionLatex(result.solutions),
      ),
    );

    if (result.validSolutions.length != result.solutions.length) {
      steps.add(
        SolutionStep(
          inputLatex: _solutionLatex(result.solutions),
          description: 'Vérifier les solutions dans l’équation initiale afin d’écarter les solutions extrinsèques.',
          outputLatex: _solutionLatex(result.validSolutions),
        ),
      );
    }

    return MathSolution(
      problemLatex: inputLatex,
      steps: steps,
      finalAnswerLatex: _solutionLatex(result.validSolutions),
    );
  }

  MathSolution? _solveDoubleRadical(
    Expr left,
    Expr right,
    List<SolutionStep> steps,
    String inputLatex,
  ) {
    final isolate = _isolateOneOfTwoSqrt(left, right);
    if (isolate == null) return null;

    final sqrtExpr = isolate.sqrtExpr;
    final otherSide = isolate.otherSide;

    steps.add(
      SolutionStep(
        inputLatex: inputLatex,
        description: 'Isoler une des expressions radicales.',
        outputLatex: _equationLatex(sqrtExpr, otherSide),
      ),
    );

    final sqrtArg = _sqrtArg(sqrtExpr);
    final squaredLeft = sqrtArg ?? Pow(sqrtExpr, const Num(2));
    final squaredRight = Pow(otherSide, const Num(2));
    steps.add(
      SolutionStep(
        inputLatex: _equationLatex(sqrtExpr, otherSide),
        description: 'Élever les deux membres au carré pour réduire le nombre de racines.',
        outputLatex: _equationLatex(squaredLeft, squaredRight),
      ),
    );

    if (squaredLeft.sqrtCount() + squaredRight.sqrtCount() > 1) {
      return null;
    }

    final afterFirstLeft = _simplifier.simplify(squaredLeft);
    final afterFirstRight = _simplifier.simplify(squaredRight);

    final isolateSecond = _isolateSingleSqrt(afterFirstLeft, afterFirstRight);
    if (isolateSecond == null) return null;

    final sqrt2 = isolateSecond.sqrtExpr;
    final other2 = isolateSecond.otherSide;
    steps.add(
      SolutionStep(
        inputLatex: _equationLatex(afterFirstLeft, afterFirstRight),
        description: 'Isoler la deuxième expression radicale.',
        outputLatex: _equationLatex(sqrt2, other2),
      ),
    );

    final sqrtArg2 = _sqrtArg(sqrt2);
    final squaredLeft2 = sqrtArg2 ?? Pow(sqrt2, const Num(2));
    final squaredRight2 = Pow(other2, const Num(2));
    steps.add(
      SolutionStep(
        inputLatex: _equationLatex(sqrt2, other2),
        description: 'Élever les deux membres au carré une seconde fois.',
        outputLatex: _equationLatex(squaredLeft2, squaredRight2),
      ),
    );

    final poly = _simplifier.simplify(Sub(squaredLeft2, squaredRight2)).toPoly();
    if (poly == null) {
      final standardExpr = _simplifier.simplify(Sub(squaredLeft2, squaredRight2));
      final standard = _equationLatex(standardExpr, const Num(0));
      final higher = _solveHigherDegreePolynomial(standardExpr, left, right, domainMin: 0);
      if (higher == null) return null;
      steps.add(
        SolutionStep(
          inputLatex: _equationLatex(squaredLeft2, squaredRight2),
          description: 'Ramener Ã  la forme f(x) = 0.',
          outputLatex: standard,
        ),
      );
      steps.add(
        SolutionStep(
          inputLatex: standard,
          description: 'RÃ©soudre numÃ©riquement lâ€™Ã©quation polynomiale obtenue.',
          outputLatex: _solutionLatex(higher.solutions),
        ),
      );
      if (higher.validSolutions.length != higher.solutions.length) {
        steps.add(
          SolutionStep(
            inputLatex: _solutionLatex(higher.solutions),
            description: 'VÃ©rifier les solutions dans lâ€™Ã©quation initiale afin dâ€™Ã©carter les solutions extrinsÃ¨ques.',
            outputLatex: _solutionLatex(higher.validSolutions),
          ),
        );
      }
      return MathSolution(
        problemLatex: inputLatex,
        steps: steps,
        finalAnswerLatex: _solutionLatex(higher.validSolutions),
      );
    }

    final standardExpr = _simplifier.simplify(Sub(squaredLeft2, squaredRight2));
    final standard = _equationLatex(standardExpr, const Num(0));
    steps.add(
      SolutionStep(
        inputLatex: _equationLatex(squaredLeft2, squaredRight2),
        description: 'Ramener à la forme f(x) = 0.',
        outputLatex: standard,
      ),
    );

    final result = _solver.solveAndValidate(left, right, poly);
    steps.add(
      SolutionStep(
        inputLatex: standard,
        description: 'Résoudre l’équation algébrique obtenue.',
        outputLatex: _solutionLatex(result.solutions),
      ),
    );

    if (result.validSolutions.length != result.solutions.length) {
      steps.add(
        SolutionStep(
          inputLatex: _solutionLatex(result.solutions),
          description: 'Vérifier les solutions dans l’équation initiale afin d’écarter les solutions extrinsèques.',
          outputLatex: _solutionLatex(result.validSolutions),
        ),
      );
    }

    return MathSolution(
      problemLatex: inputLatex,
      steps: steps,
      finalAnswerLatex: _solutionLatex(result.validSolutions),
    );
  }
}

class _IsolationResult {
  final Expr sqrtExpr;
  final Expr otherSide;

  const _IsolationResult(this.sqrtExpr, this.otherSide);
}

_IsolationResult? _isolateSingleSqrt(Expr left, Expr right) {
  if (_hasTopLevelSqrt(left) && right.sqrtCount() == 0) {
    return _isolate(left, right);
  }
  if (_hasTopLevelSqrt(right) && left.sqrtCount() == 0) {
    return _isolate(right, left);
  }
  return null;
}

_IsolationResult? _isolateOneOfTwoSqrt(Expr left, Expr right) {
  if (left.sqrtCount() == 2 && right.sqrtCount() == 0) {
    return _isolateRadicalSum(left, right);
  }
  if (right.sqrtCount() == 2 && left.sqrtCount() == 0) {
    return _isolateRadicalSum(right, left);
  }
  if (left.sqrtCount() == 1 && right.sqrtCount() == 1) {
    return _isolateRadicalSum(left, right);
  }
  return null;
}

_IsolationResult? _isolateRadicalSum(Expr radicalSide, Expr otherSide) {
  if (radicalSide is Add) {
    if (_isSqrtExpr(radicalSide.left) && _isSqrtExpr(radicalSide.right)) {
      return _IsolationResult(
        radicalSide.left,
        Sub(otherSide, radicalSide.right),
      );
    }
    if (_isSqrtExpr(radicalSide.left) && !radicalSide.right.containsSqrt()) {
      return _IsolationResult(
        radicalSide.left,
        Sub(otherSide, radicalSide.right),
      );
    }
    if (_isSqrtExpr(radicalSide.right) && !radicalSide.left.containsSqrt()) {
      return _IsolationResult(
        radicalSide.right,
        Sub(otherSide, radicalSide.left),
      );
    }
  }
  if (radicalSide is Sub) {
    if (_isSqrtExpr(radicalSide.left) && !radicalSide.right.containsSqrt()) {
      return _IsolationResult(
        radicalSide.left,
        Add(otherSide, radicalSide.right),
      );
    }
    if (_isSqrtExpr(radicalSide.right) && !radicalSide.left.containsSqrt()) {
      return _IsolationResult(
        radicalSide.right,
        Sub(radicalSide.left, otherSide),
      );
    }
  }
  if (_isSqrtExpr(radicalSide)) {
    return _IsolationResult(radicalSide, otherSide);
  }
  return null;
}

_IsolationResult? _isolate(Expr sideWithSqrt, Expr otherSide) {
  if (_isSqrtExpr(sideWithSqrt)) {
    return _IsolationResult(sideWithSqrt, otherSide);
  }
  if (sideWithSqrt is Add) {
    if (_isSqrtExpr(sideWithSqrt.left) && !sideWithSqrt.right.containsSqrt()) {
      return _IsolationResult(sideWithSqrt.left, Sub(otherSide, sideWithSqrt.right));
    }
    if (_isSqrtExpr(sideWithSqrt.right) && !sideWithSqrt.left.containsSqrt()) {
      return _IsolationResult(sideWithSqrt.right, Sub(otherSide, sideWithSqrt.left));
    }
  }
  if (sideWithSqrt is Sub) {
    if (_isSqrtExpr(sideWithSqrt.left) && !sideWithSqrt.right.containsSqrt()) {
      return _IsolationResult(sideWithSqrt.left, Add(otherSide, sideWithSqrt.right));
    }
    if (_isSqrtExpr(sideWithSqrt.right) && !sideWithSqrt.left.containsSqrt()) {
      return _IsolationResult(sideWithSqrt.right, Sub(sideWithSqrt.left, otherSide));
    }
  }
  return null;
}

String _equationLatex(Expr left, Expr right) {
  return '${left.toLatex()} = ${right.toLatex()}';
}

String _solutionLatex(List<double> values) {
  if (values.isEmpty) {
    return r'\text{Aucune solution}';
  }
  if (values.length == 1) {
    return r'x = ' + _fmt(values.first);
  }
  return r'x_1 = ' + _fmt(values[0]) + r',\; x_2 = ' + _fmt(values[1]);
}

String _fmt(double value) {
  var text = value.toStringAsFixed(6);
  text = text.replaceAll(RegExp(r'0+$'), '');
  text = text.replaceAll(RegExp(r'\.$'), '');
  if (text == '-0') return '0';
  return text;
}

bool _containsUnknownIdentifiers(String input) {
  final tokens = RegExp(r'[a-zA-Z]+').allMatches(input).map((m) => m.group(0) ?? '');
  for (final token in tokens) {
    if (token == 'x' ||
        token == 'sqrt' ||
        token == 'sin' ||
        token == 'cos' ||
        token == 'tan' ||
        token == 'log' ||
        token == 'ln' ||
        token == 'pi' ||
        token == 'e') {
      continue;
    }
    return true;
  }
  return false;
}

MathSolution? _solveTrigEquation(Expr left, Expr right, String inputLatex) {
  final leftTrig = _asTrig(left);
  final rightTrig = _asTrig(right);

  if (leftTrig != null && rightTrig == null) {
    return _solveTrigValue(leftTrig, right, inputLatex);
  }
  if (rightTrig != null && leftTrig == null) {
    return _solveTrigValue(rightTrig, left, inputLatex);
  }
  if (leftTrig != null && rightTrig != null) {
    if (leftTrig.func == 'sin' && rightTrig.func == 'cos' && _isArgX(leftTrig) && _isArgX(rightTrig)) {
      return _solveSinEqualsCos(inputLatex);
    }
  }
  return null;
}

MathSolution? _solveTrigValue(_TrigCall trig, Expr valueExpr, String inputLatex) {
  if (!_isArgX(trig)) return null;
  if (_containsVar(valueExpr)) return null;
  final value = valueExpr.eval({'x': 0});
  if (value == null) return null;
  final valueLatex = valueExpr.toLatex();
  final eqLatex = '${trig.func}(x) = $valueLatex';

  final steps = <SolutionStep>[
    SolutionStep(
      inputLatex: inputLatex,
      description: 'Reconnaître une équation trigonométrique.',
      outputLatex: eqLatex,
    ),
    SolutionStep(
      inputLatex: eqLatex,
      description: 'Appliquer la formule de solution générale.',
      outputLatex: _generalTrigSolution(trig.func, valueLatex),
    ),
  ];

  return MathSolution(
    problemLatex: inputLatex,
    steps: steps,
    finalAnswerLatex: _generalTrigSolution(trig.func, valueLatex),
  );
}

String _generalTrigSolution(String func, String valueLatex) {
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
  return r'x \in \mathbb{R}';
}

MathSolution _solveSinEqualsCos(String inputLatex) {
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

class _TrigCall {
  final String func;
  final Expr arg;

  const _TrigCall(this.func, this.arg);
}

_TrigCall? _asTrig(Expr expr) {
  if (expr is Func) {
    if (expr.name == 'sin') return _TrigCall('sin', expr.arg);
    if (expr.name == 'cos') return _TrigCall('cos', expr.arg);
    if (expr.name == 'tan') return _TrigCall('tan', expr.arg);
  }
  if (expr is Sin) return _TrigCall('sin', expr.arg);
  if (expr is Cos) return _TrigCall('cos', expr.arg);
  if (expr is Tan) return _TrigCall('tan', expr.arg);
  return null;
}

bool _isArgX(_TrigCall call) => call.arg is Var && (call.arg as Var).name == 'x';

bool _containsVar(Expr expr) {
  if (expr is Var) return true;
  if (expr is Num || expr is Const) return false;
  if (expr is Neg) return _containsVar(expr.value);
  if (expr is Func) return _containsVar(expr.arg);
  if (expr is Sin) return _containsVar(expr.arg);
  if (expr is Cos) return _containsVar(expr.arg);
  if (expr is Tan) return _containsVar(expr.arg);
  if (expr is Log) return _containsVar(expr.arg);
  if (expr is Ln) return _containsVar(expr.arg);
  if (expr is Sqrt) return _containsVar(expr.radicand);
  if (expr is Add) return _containsVar(expr.left) || _containsVar(expr.right);
  if (expr is Sub) return _containsVar(expr.left) || _containsVar(expr.right);
  if (expr is Mul) return _containsVar(expr.left) || _containsVar(expr.right);
  if (expr is Div) return _containsVar(expr.left) || _containsVar(expr.right);
  if (expr is Pow) return _containsVar(expr.base) || _containsVar(expr.exp);
  return false;
}

bool _hasTopLevelSqrt(Expr expr) {
  if (_isSqrtExpr(expr)) return true;
  if (expr is Add) {
    return _isSqrtExpr(expr.left) || _isSqrtExpr(expr.right);
  }
  if (expr is Sub) {
    return _isSqrtExpr(expr.left) || _isSqrtExpr(expr.right);
  }
  return false;
}

MathSolution? _solveRadicalProductLinear(Expr left, Expr right, String inputLatex) {
  final diff = Sub(left, right);
  final match = _matchRadicalProduct(diff);
  if (match == null) return null;

  final steps = <SolutionStep>[
    SolutionStep(
      inputLatex: inputLatex,
      description: 'Pr?ciser le domaine de d?finition : x \\ge 0.',
      outputLatex: r'x \\ge 0',
    ),
    SolutionStep(
      inputLatex: inputLatex,
      description: 'Regrouper les termes et r??crire avec des puissances fractionnaires.',
      outputLatex: match.rewrittenLatex + r' = 0',
    ),
    SolutionStep(
      inputLatex: match.rewrittenLatex + r' = 0',
      description: 'Mettre en facteur la plus petite puissance de x.',
      outputLatex: match.factoredLatex + r' = 0',
    ),
    SolutionStep(
      inputLatex: match.factoredLatex + r' = 0',
      description: 'Appliquer la propri?t? du produit nul.',
      outputLatex: match.caseLatex,
    ),
    SolutionStep(
      inputLatex: match.caseLatex,
      description: 'Conserver uniquement la solution compatible avec le domaine.',
      outputLatex: match.finalLatex,
    ),
  ];

  return MathSolution(
    problemLatex: inputLatex,
    steps: steps,
    finalAnswerLatex: match.finalLatex,
  );
}

class _RadicalProductMatch {
  final String rewrittenLatex;
  final String factoredLatex;
  final String caseLatex;
  final String finalLatex;

  const _RadicalProductMatch({
    required this.rewrittenLatex,
    required this.factoredLatex,
    required this.caseLatex,
    required this.finalLatex,
  });
}

_RadicalProductMatch? _matchRadicalProduct(Expr expr) {
  final terms = _collectTerms(expr);
  if (terms.isEmpty) return null;

  double coeffX2 = 0;
  double coeffXSqrtX = 0;
  double coeffX = 0;

  for (final term in terms) {
    final kx2 = _extractCoeffX2(term);
    if (kx2 != null) {
      coeffX2 += kx2;
      continue;
    }
    final kxs = _extractCoeffXSqrtX(term);
    if (kxs != null) {
      coeffXSqrtX += kxs;
      continue;
    }
    final kx = _extractCoeffX(term);
    if (kx != null) {
      coeffX += kx;
      continue;
    }
    return null;
  }

  if (coeffXSqrtX.abs() < 1e-9) return null;

  if (coeffX2.abs() > 1e-9 && coeffX.abs() < 1e-9) {
    final rewritten = '${_fmt(coeffX2)}x^2 + ${_fmt(coeffXSqrtX)}x^{3/2}';
    final factored = r'x^{3/2}(' + _fmt(coeffX2) + r'x^{1/2} + ' + _fmt(coeffXSqrtX) + r')';
    final caseLatex = r'x^{3/2} = 0 \\;\\; \\text{ou} \\;\\; ' +
        _fmt(coeffX2) +
        r'x^{1/2} + ' +
        _fmt(coeffXSqrtX) +
        r' = 0';
    final rhs = -coeffXSqrtX / coeffX2;
    final finalLatex = rhs >= 0 ? r'x = 0 \\;\\; \\text{ou} \\;\\; x = ' + _fmt(rhs * rhs) : r'x = 0';
    return _RadicalProductMatch(
      rewrittenLatex: rewritten,
      factoredLatex: factored,
      caseLatex: caseLatex,
      finalLatex: finalLatex,
    );
  }

  if (coeffX.abs() > 1e-9 && coeffX2.abs() < 1e-9) {
    final rewritten = '${_fmt(coeffXSqrtX)}x^{3/2} + ${_fmt(coeffX)}x';
    final factored = r'x(' + _fmt(coeffXSqrtX) + r'\\sqrt{x} + ' + _fmt(coeffX) + r')';
    final caseLatex = r'x = 0 \\;\\; \\text{ou} \\;\\; ' +
        _fmt(coeffXSqrtX) +
        r'\\sqrt{x} + ' +
        _fmt(coeffX) +
        r' = 0';
    final rhs = -coeffX / coeffXSqrtX;
    final finalLatex = rhs >= 0 ? r'x = 0 \\;\\; \\text{ou} \\;\\; x = ' + _fmt(rhs * rhs) : r'x = 0';
    return _RadicalProductMatch(
      rewrittenLatex: rewritten,
      factoredLatex: factored,
      caseLatex: caseLatex,
      finalLatex: finalLatex,
    );
  }

  return null;
}

List<Expr> _collectTerms(Expr expr) {
  if (expr is Add) {
    return [..._collectTerms(expr.left), ..._collectTerms(expr.right)];
  }
  if (expr is Sub) {
    return [..._collectTerms(expr.left), Mul(const Num(-1), expr.right)];
  }
  return [expr];
}

bool _isX2(Expr expr) {
  if (expr is Pow && expr.base is Var && (expr.base as Var).name == 'x' && expr.exp is Num) {
    return ((expr.exp as Num).value - 2).abs() < 1e-9;
  }
  if (expr is Mul && expr.left is Num && (expr.left as Num).value == 1) {
    return _isX2(expr.right);
  }
  return false;
}

bool _isXSqrtX(Expr expr) {
  if (expr is Mul) {
    return (_isX(expr.left) && _isSqrtX(expr.right)) ||
        (_isX(expr.right) && _isSqrtX(expr.left));
  }
  return false;
}

bool _isX(Expr expr) => expr is Var && expr.name == 'x';

bool _isSqrtX(Expr expr) {
  if (expr is Sqrt && expr.radicand is Var && (expr.radicand as Var).name == 'x') return true;
  if (expr is Func && expr.name == 'sqrt' && expr.arg is Var && (expr.arg as Var).name == 'x') return true;
  return false;
}

bool _isSqrtExpr(Expr expr) {
  if (expr is Sqrt) return true;
  if (expr is Func && expr.name == 'sqrt') return true;
  return false;
}

Expr? _sqrtArg(Expr expr) {
  if (expr is Sqrt) return expr.radicand;
  if (expr is Func && expr.name == 'sqrt') return expr.arg;
  return null;
}

double? _extractCoeffX2(Expr expr) {
  if (_isX2(expr)) return 1;
  if (expr is Mul) {
    final num = _asNumber(expr.left);
    if (num != null && _isX2(expr.right)) return num;
    final num2 = _asNumber(expr.right);
    if (num2 != null && _isX2(expr.left)) return num2;
  }
  return null;
}

double? _extractCoeffX(Expr expr) {
  if (_isX(expr)) return 1;
  if (expr is Mul) {
    final num = _asNumber(expr.left);
    if (num != null && _isX(expr.right)) return num;
    final num2 = _asNumber(expr.right);
    if (num2 != null && _isX(expr.left)) return num2;
  }
  return null;
}

double? _extractCoeffXSqrtX(Expr expr) {
  if (_isXSqrtX(expr)) return 1;
  if (expr is Mul) {
    final num = _asNumber(expr.left);
    if (num != null && _isXSqrtX(expr.right)) return num;
    final num2 = _asNumber(expr.right);
    if (num2 != null && _isXSqrtX(expr.left)) return num2;
  }
  return null;
}

MathSolution? _solveLinearSymbolic(Expr left, Expr right, String inputLatex) {
  final diff = Sub(left, right);
  final linear = _decomposeLinear(diff);
  if (linear == null) return null;

  final coeff = linear.coeff;
  final constant = linear.constant;

  if (_isZeroExpr(coeff)) return null;

  final steps = <SolutionStep>[
    SolutionStep(
      inputLatex: inputLatex,
      description: 'Ramener tous les termes dans un seul membre.',
      outputLatex: '${diff.toLatex()} = 0',
    ),
    SolutionStep(
      inputLatex: '${diff.toLatex()} = 0',
      description: 'Isoler le terme en x.',
      outputLatex: '${coeff.toLatex()} \\cdot x = ${_negExpr(constant).toLatex()}',
    ),
    SolutionStep(
      inputLatex: '${coeff.toLatex()} \\cdot x = ${_negExpr(constant).toLatex()}',
      description: 'Diviser par le coefficient de x.',
      outputLatex: r'x = \frac{' +
          _negExpr(constant).toLatex() +
          '}{' +
          coeff.toLatex() +
          '}',
    ),
  ];

  final rationalization = _rationalizeIfNeeded(_negExpr(constant), coeff);
  if (rationalization != null) {
    steps.add(
      SolutionStep(
        inputLatex: r'x = \frac{' +
            _negExpr(constant).toLatex() +
            '}{' +
            coeff.toLatex() +
            '}',
        description: 'Rationaliser le d?nominateur par le conjugu?.',
        outputLatex: r'x = ' + rationalization.rawLatex,
      ),
    );
    if (rationalization.expandedLatex != null) {
      steps.add(
        SolutionStep(
          inputLatex: r'x = ' + rationalization.rawLatex,
          description: 'D?velopper le num?rateur.',
          outputLatex: r'x = ' + rationalization.expandedLatex!,
        ),
      );
    }
    if (rationalization.simplifiedLatex != null &&
        rationalization.simplifiedLatex != rationalization.expandedLatex) {
      steps.add(
        SolutionStep(
          inputLatex: r'x = ' + (rationalization.expandedLatex ?? rationalization.rawLatex),
          description: 'Simplifier l\'expression obtenue.',
          outputLatex: r'x = ' + rationalization.simplifiedLatex!,
        ),
      );
    }
  }

  final finalLatex = rationalization != null
      ? r'x = ' +
          (rationalization.simplifiedLatex ??
              rationalization.expandedLatex ??
              rationalization.rawLatex)
      : r'x = \frac{' + _negExpr(constant).toLatex() + '}{' + coeff.toLatex() + '}';

  return MathSolution(
    problemLatex: inputLatex,
    steps: steps,
    finalAnswerLatex: finalLatex,
  );
}

class _LinearDecomposition {
  final Expr coeff;
  final Expr constant;

  const _LinearDecomposition(this.coeff, this.constant);
}

_LinearDecomposition? _decomposeLinear(Expr expr) {
  if (expr is Num || expr is Const || expr is Sqrt || expr is Log || expr is Ln || expr is Sin || expr is Cos || expr is Tan) {
    if (_containsVar(expr)) return null;
    return _LinearDecomposition(const Num(0), expr);
  }
  if (expr is Var && expr.name == 'x') {
    return _LinearDecomposition(const Num(1), const Num(0));
  }
  if (expr is Add) {
    final l = _decomposeLinear(expr.left);
    final r = _decomposeLinear(expr.right);
    if (l == null || r == null) return null;
    return _LinearDecomposition(
      _addExpr(l.coeff, r.coeff),
      _addExpr(l.constant, r.constant),
    );
  }
  if (expr is Sub) {
    final l = _decomposeLinear(expr.left);
    final r = _decomposeLinear(expr.right);
    if (l == null || r == null) return null;
    return _LinearDecomposition(
      _subExpr(l.coeff, r.coeff),
      _subExpr(l.constant, r.constant),
    );
  }
  if (expr is Mul) {
    if (_containsVar(expr.left) && _containsVar(expr.right)) return null;
    if (_containsVar(expr.left)) {
      final left = _decomposeLinear(expr.left);
      if (left == null || !_isZeroExpr(left.constant)) return null;
      return _LinearDecomposition(_mulExpr(expr.right, left.coeff), const Num(0));
    }
    if (_containsVar(expr.right)) {
      final right = _decomposeLinear(expr.right);
      if (right == null || !_isZeroExpr(right.constant)) return null;
      return _LinearDecomposition(_mulExpr(expr.left, right.coeff), const Num(0));
    }
    return _LinearDecomposition(const Num(0), expr);
  }
  if (expr is Div) {
    if (_containsVar(expr.right)) return null;
    final left = _decomposeLinear(expr.left);
    if (left == null) return null;
    return _LinearDecomposition(
      _divExpr(left.coeff, expr.right),
      _divExpr(left.constant, expr.right),
    );
  }
  return null;
}

Expr _addExpr(Expr a, Expr b) => Add(a, b);
Expr _subExpr(Expr a, Expr b) => Sub(a, b);
Expr _mulExpr(Expr a, Expr b) => Mul(a, b);
Expr _divExpr(Expr a, Expr b) => Div(a, b);
Expr _negExpr(Expr a) => Mul(const Num(-1), a);

bool _isZeroExpr(Expr expr) => expr is Num && expr.value.abs() < 1e-9;

_RationalizationResult? _rationalizeIfNeeded(Expr numerator, Expr denominator) {
  final doubleMatch = _matchDoubleRadicalDenominator(denominator);
  if (doubleMatch != null) {
    final a = doubleMatch.a;
    final b = doubleMatch.b;
    final c = doubleMatch.c;
    final d = doubleMatch.d;
    final e = doubleMatch.e;

    final conj1 = '(${_fmt(a)} + ${_fmt(b)}\\sqrt{${_fmt(c)}} - ${_fmt(d)}\\sqrt{${_fmt(e)}})';
    final u = a * a + b * b * c - d * d * e;
    final v = 2 * a * b;
    final conj2 = '(${_fmt(u)} - ${_fmt(v)}\\sqrt{${_fmt(c)}})';
    final denomFinal = u * u - (v * v * c);

    final numeratorLatex = '${numerator.toLatex()}\\cdot$conj1\\cdot$conj2';
    return _RationalizationResult(
      rawLatex: r'\\frac{' + numeratorLatex + '}{' + _fmt(denomFinal) + '}',
      expandedLatex: null,
      simplifiedLatex: null,
    );
  }

  final match = _matchRadicalDenominator(denominator);
  if (match == null) return null;
  final a = match.a;
  final b = match.b;
  final c = match.c;
  final conj = _buildConjugate(a, b, c, match.plus);
  final denomValue = a * a - (b * b * c);

  final binomial = _matchRadicalBinomial(numerator, c);
  if (binomial != null) {
    final expanded = _expandRadicalBinomial(binomial.a, binomial.b, c, a, match.plus ? -b : b);
    return _RationalizationResult(
      rawLatex: r'\\frac{' + numerator.toLatex() + '\\cdot' + conj + '}{' + _fmt(denomValue) + '}',
      expandedLatex: r'\\frac{' + expanded + '}{' + _fmt(denomValue) + '}',
      simplifiedLatex: null,
    );
  }

  final numeratorLatex = '${numerator.toLatex()}\\cdot$conj';
  return _RationalizationResult(
    rawLatex: r'\\frac{' + numeratorLatex + '}{' + _fmt(denomValue) + '}',
    expandedLatex: null,
    simplifiedLatex: null,
  );
}

class _RationalizationResult {
  final String rawLatex;
  final String? expandedLatex;
  final String? simplifiedLatex;

  const _RationalizationResult({
    required this.rawLatex,
    required this.expandedLatex,
    required this.simplifiedLatex,
  });
}

class _RadicalDenominatorMatch {
  final double a;
  final double b;
  final double c;
  final bool plus;

  const _RadicalDenominatorMatch(this.a, this.b, this.c, this.plus);
}

_RadicalDenominatorMatch? _matchRadicalDenominator(Expr expr) {
  if (expr is Add || expr is Sub) {
    final left = expr is Add ? expr.left : (expr as Sub).left;
    final right = expr is Add ? expr.right : (expr as Sub).right;
    final plus = expr is Add;
    final a = _asNumber(left);
    final radical = _asSqrtNumber(right);
    if (a != null && radical != null) {
      return _RadicalDenominatorMatch(a, radical.b, radical.c, plus);
    }
    final b = _asNumber(right);
    final radical2 = _asSqrtNumber(left);
    if (b != null && radical2 != null) {
      return _RadicalDenominatorMatch(b, radical2.b, radical2.c, plus);
    }
  }
  return null;
}

class _SqrtNumberMatch {
  final double b;
  final double c;
  const _SqrtNumberMatch(this.b, this.c);
}

double? _asNumber(Expr expr) {
  if (expr is Num) return expr.value;
  if (expr is Const && expr.symbol == 'pi') return math.pi;
  if (expr is Const && expr.symbol == 'e') return math.e;
  return null;
}

_SqrtNumberMatch? _asSqrtNumber(Expr expr) {
  if (expr is Sqrt && expr.radicand is Num) {
    return _SqrtNumberMatch(1, (expr.radicand as Num).value);
  }
  if (expr is Func && expr.name == 'sqrt' && expr.arg is Num) {
    return _SqrtNumberMatch(1, (expr.arg as Num).value);
  }
  if (expr is Mul) {
    final num = _asNumber(expr.left);
    final sqrt = _asSqrtNumber(expr.right);
    if (num != null && sqrt != null) {
      return _SqrtNumberMatch(num, sqrt.c);
    }
    final num2 = _asNumber(expr.right);
    final sqrt2 = _asSqrtNumber(expr.left);
    if (num2 != null && sqrt2 != null) {
      return _SqrtNumberMatch(num2, sqrt2.c);
    }
  }
  return null;
}

String _buildConjugate(double a, double b, double c, bool plus) {
  final sign = plus ? '-' : '+';
  return '(${_fmt(a)} $sign ${_fmt(b)}\\sqrt{${_fmt(c)}})';
}


_RadicalBinomial? _matchRadicalBinomial(Expr expr, double c) {
  if (expr is Add || expr is Sub) {
    final left = expr is Add ? expr.left : (expr as Sub).left;
    final right = expr is Add ? expr.right : (expr as Sub).right;
    final a = _asNumber(left);
    final radical = _asSqrtNumber(right);
    if (a != null && radical != null && (radical.c - c).abs() < 1e-9) {
      final b = expr is Add ? radical.b : -radical.b;
      return _RadicalBinomial(a, b);
    }
    final a2 = _asNumber(right);
    final radical2 = _asSqrtNumber(left);
    if (a2 != null && radical2 != null && (radical2.c - c).abs() < 1e-9) {
      final b = expr is Add ? radical2.b : -radical2.b;
      return _RadicalBinomial(a2, b);
    }
  }
  if (_asNumber(expr) != null) {
    return _RadicalBinomial(_asNumber(expr)!, 0);
  }
  return null;
}

class _RadicalBinomial {
  final double a;
  final double b;

  const _RadicalBinomial(this.a, this.b);
}

String _expandRadicalBinomial(double a, double b, double c, double d, double e) {
  final constPart = a * d + b * e * c;
  final radicalPart = a * e + b * d;
  final sign = radicalPart >= 0 ? '+' : '-';
  final abs = radicalPart.abs();
  return '${_fmt(constPart)} $sign ${_fmt(abs)}\\sqrt{${_fmt(c)}}';
}

_RadicalDenominatorDouble? _matchDoubleRadicalDenominator(Expr expr) {
  if (expr is Add || expr is Sub) {
    final parts = _collectTerms(expr);
    if (parts.length != 3) return null;
    double? a;
    _SqrtNumberMatch? r1;
    _SqrtNumberMatch? r2;
    for (final part in parts) {
      final n = _asNumber(part);
      if (n != null && a == null) {
        a = n;
        continue;
      }
      final r = _asSqrtNumber(part);
      if (r != null && r1 == null) {
        r1 = r;
        continue;
      }
      if (r != null && r2 == null) {
        r2 = r;
        continue;
      }
    }
    if (a != null && r1 != null && r2 != null) {
      return _RadicalDenominatorDouble(a, r1.b, r1.c, r2.b, r2.c);
    }
  }
  return null;
}

class _RadicalDenominatorDouble {
  final double a;
  final double b;
  final double c;
  final double d;
  final double e;

  const _RadicalDenominatorDouble(this.a, this.b, this.c, this.d, this.e);
}

MathSolution? _solveLogEquation(Expr left, Expr right, String inputLatex) {
  final leftLog = _asLog(left);
  final rightLog = _asLog(right);

  if (leftLog != null && rightLog == null) {
    return _solveLogValue(leftLog, right, inputLatex);
  }
  if (rightLog != null && leftLog == null) {
    return _solveLogValue(rightLog, left, inputLatex);
  }
  return null;
}

MathSolution? _solveLogValue(_LogCall logCall, Expr valueExpr, String inputLatex) {
  if (_containsVar(valueExpr)) return null;
  final value = valueExpr.eval({'x': 0});
  if (value == null) return null;

  final base = logCall.isLn ? math.e : 10.0;
  final baseLatex = logCall.isLn ? 'e' : '10';

  final steps = <SolutionStep>[
    SolutionStep(
      inputLatex: inputLatex,
      description: 'Reconnaître une équation logarithmique.',
      outputLatex: '${logCall.toLatex()} = ${valueExpr.toLatex()}',
    ),
    SolutionStep(
      inputLatex: '${logCall.toLatex()} = ${valueExpr.toLatex()}',
      description: 'Exponentier les deux membres pour lever le logarithme.',
      outputLatex: '${logCall.arg.toLatex()} = ${baseLatex}^{${valueExpr.toLatex()}}',
    ),
  ];

  final constant = math.pow(base, value).toDouble();
  final poly = Sub(logCall.arg, Num(constant)).toPoly();
  if (poly == null) return null;

  final standard = '${logCall.arg.toLatex()} = ${_fmt(constant)}';
  steps.add(
    SolutionStep(
      inputLatex: '${logCall.arg.toLatex()} = ${baseLatex}^{${valueExpr.toLatex()}}',
      description: 'Évaluer la puissance pour obtenir une équation algébrique.',
      outputLatex: standard,
    ),
  );

  final solver = CasSolver();
  final result = solver.solveAndValidate(logCall.arg, Num(constant), poly);
  steps.add(
    SolutionStep(
      inputLatex: standard,
      description: 'Résoudre l’équation obtenue.',
      outputLatex: _solutionLatex(result.solutions),
    ),
  );

  if (result.validSolutions.length != result.solutions.length) {
    steps.add(
      SolutionStep(
        inputLatex: _solutionLatex(result.solutions),
        description: 'Vérifier les solutions dans l’équation initiale afin d’écarter les solutions extrinsèques.',
        outputLatex: _solutionLatex(result.validSolutions),
      ),
    );
  }

  return MathSolution(
    problemLatex: inputLatex,
    steps: steps,
    finalAnswerLatex: _solutionLatex(result.validSolutions),
  );
}

class _LogCall {
  final bool isLn;
  final Expr arg;

  const _LogCall(this.isLn, this.arg);

  String toLatex() => isLn ? r'\ln(' + arg.toLatex() + ')' : r'\log(' + arg.toLatex() + ')';
}

_LogCall? _asLog(Expr expr) {
  if (expr is Func) {
    if (expr.name == 'ln') return _LogCall(true, expr.arg);
    if (expr.name == 'log') return _LogCall(false, expr.arg);
  }
  if (expr is Ln) return _LogCall(true, expr.arg);
  if (expr is Log) return _LogCall(false, expr.arg);
  return null;
}


MathSolution? _solveInequalityAst(
  String rawInput,
  RelOp op,
  Expr left,
  Expr right,
  CasSimplifier simplifier,
) {
  final inputLatex = latexFromRaw(rawInput);
  final steps = <SolutionStep>[];
  final diff = simplifier.simplify(Sub(left, right));
  final poly = diff.toPoly();
  if (poly == null) return null;

  final opLatex = _opLatex(relOpToString(op));
  final standardLatex = '${diff.toLatex()} $opLatex 0';
  steps.add(
    SolutionStep(
      inputLatex: inputLatex,
      description: 'Ramener l?in?quation sous la forme f(x) $opLatex 0.',
      outputLatex: standardLatex,
    ),
  );

  final solutionLatex = _solveInequalityPoly(poly, relOpToString(op));
  steps.add(
    SolutionStep(
      inputLatex: standardLatex,
      description: '?tudier le signe du polyn?me et en d?duire l?ensemble-solution.',
      outputLatex: solutionLatex,
    ),
  );

  return MathSolution(
    problemLatex: inputLatex,
    steps: steps,
    finalAnswerLatex: solutionLatex,
  );
}

String _opLatex(String op) {
  switch (op) {
    case '<=':
      return r'\le';
    case '>=':
      return r'\ge';
    case '<':
      return '<';
    case '>':
      return '>';
  }
  return op;
}

String _solveInequalityPoly(Poly poly, String op) {
  final a = poly.a;
  final b = poly.b;
  final c = poly.c;
  if (a.abs() < 1e-9) {
    return _solveLinearInequality(b, c, op);
  }
  final delta = b * b - 4 * a * c;
  if (delta < 0) {
    final sign = a > 0 ? 1 : -1;
    return _allOrNone(op, sign);
  }
  final sqrt = delta == 0 ? 0.0 : math.sqrt(delta);
  final r1 = (-b - sqrt) / (2 * a);
  final r2 = (-b + sqrt) / (2 * a);
  final lo = r1 < r2 ? r1 : r2;
  final hi = r1 < r2 ? r2 : r1;
  final aPositive = a > 0;
  return _quadraticIntervals(op, lo, hi, aPositive);
}

String _solveLinearInequality(double b, double c, String op) {
  if (b.abs() < 1e-9) {
    final isTrue = _compareZero(c, op);
    return isTrue ? r'x \in \mathbb{R}' : r'\text{Aucune solution}';
  }
  final root = -c / b;
  final isLess = op == '<' || op == '<=';
  final flip = b < 0;
  final actualLess = flip ? !isLess : isLess;
  final inclusive = op == '<=' || op == '>=';
  if (actualLess) {
    return _intervalLatex(double.negativeInfinity, root, inclusiveLeft: false, inclusiveRight: inclusive);
  }
  return _intervalLatex(root, double.infinity, inclusiveLeft: inclusive, inclusiveRight: false);
}

bool _compareZero(double c, String op) {
  switch (op) {
    case '<':
      return c < 0;
    case '<=':
      return c <= 0;
    case '>':
      return c > 0;
    case '>=':
      return c >= 0;
  }
  return false;
}

String _allOrNone(String op, int sign) {
  final wantsPositive = op == '>' || op == '>=';
  final wantsNegative = op == '<' || op == '<=';
  if (sign > 0 && wantsPositive) return r'x \in \mathbb{R}';
  if (sign < 0 && wantsNegative) return r'x \in \mathbb{R}';
  if (sign > 0 && wantsNegative) return r'\text{Aucune solution}';
  if (sign < 0 && wantsPositive) return r'\text{Aucune solution}';
  return r'\text{Aucune solution}';
}

String _quadraticIntervals(String op, double r1, double r2, bool aPositive) {
  final inclusive = op == '<=' || op == '>=';
  final wantsLess = op == '<' || op == '<=';
  if (aPositive) {
    if (wantsLess) {
      return _intervalLatex(r1, r2, inclusiveLeft: inclusive, inclusiveRight: inclusive);
    }
    return _unionLatex(
      _intervalLatex(double.negativeInfinity, r1, inclusiveLeft: false, inclusiveRight: inclusive),
      _intervalLatex(r2, double.infinity, inclusiveLeft: inclusive, inclusiveRight: false),
    );
  }
  if (wantsLess) {
    return _unionLatex(
      _intervalLatex(double.negativeInfinity, r1, inclusiveLeft: false, inclusiveRight: inclusive),
      _intervalLatex(r2, double.infinity, inclusiveLeft: inclusive, inclusiveRight: false),
    );
  }
  return _intervalLatex(r1, r2, inclusiveLeft: inclusive, inclusiveRight: inclusive);
}

String _intervalLatex(
  double left,
  double right, {
  required bool inclusiveLeft,
  required bool inclusiveRight,
}) {
  final leftSymbol = inclusiveLeft ? '[' : '(';
  final rightSymbol = inclusiveRight ? ']' : ')';
  final leftText = left.isInfinite ? r'-\infty' : _fmt(left);
  final rightText = right.isInfinite ? r'\infty' : _fmt(right);
  return '$leftSymbol$leftText, $rightText$rightSymbol';
}

String _unionLatex(String a, String b) => '$a \\cup $b';

class _NumericSolveResult {
  final List<double> solutions;
  final List<double> validSolutions;

  const _NumericSolveResult(this.solutions, this.validSolutions);
}

_NumericSolveResult? _solveHigherDegreePolynomial(
  Expr standardExpr,
  Expr left,
  Expr right, {
  double? domainMin,
  double? domainMax,
}) {
  final poly = _PolyN.fromExpr(standardExpr);
  if (poly == null) return null;
  final coeffs = poly.coeffs;
  final maxDegree = poly.maxDegree;
  if (maxDegree <= 2) return null;

  final bound = _cauchyBound(coeffs);
  final min = domainMin ?? -bound;
  final max = domainMax ?? bound;

  final roots = _realRootsBySampling(coeffs, min, max);
  if (roots.isEmpty) return _NumericSolveResult(const [], const []);
  final valid = _validateSolutions(left, right, roots);
  return _NumericSolveResult(roots, valid);
}

double _cauchyBound(List<double> coeffs) {
  var degree = coeffs.length - 1;
  while (degree > 0 && coeffs[degree].abs() < 1e-12) {
    degree--;
  }
  final leading = coeffs[degree].abs();
  if (leading < 1e-12) return 10;
  var maxRatio = 0.0;
  for (var i = 0; i < degree; i++) {
    maxRatio = math.max(maxRatio, coeffs[i].abs() / leading);
  }
  return 1 + maxRatio;
}

List<double> _realRootsBySampling(List<double> coeffs, double min, double max) {
  const samples = 2000;
  const eps = 1e-6;
  final roots = <double>[];
  double? prevX;
  double? prevY;
  for (var i = 0; i <= samples; i++) {
    final t = i / samples;
    final x = min + (max - min) * t;
    final y = _polyEval(coeffs, x);
    if (y.abs() < eps) {
      _addUniqueRoot(roots, x);
    }
    if (prevY != null) {
      if (prevY == 0) {
        _addUniqueRoot(roots, prevX!);
      } else if (y == 0 || (prevY < 0 && y > 0) || (prevY > 0 && y < 0)) {
        final root = _bisection(coeffs, prevX!, x);
        _addUniqueRoot(roots, root);
      }
    }
    prevX = x;
    prevY = y;
  }
  roots.sort();
  return roots;
}

double _polyEval(List<double> coeffs, double x) {
  var result = 0.0;
  for (var i = coeffs.length - 1; i >= 0; i--) {
    result = result * x + coeffs[i];
  }
  return result;
}

double _bisection(List<double> coeffs, double a, double b) {
  var left = a;
  var right = b;
  var fLeft = _polyEval(coeffs, left);
  var fRight = _polyEval(coeffs, right);
  if (fLeft.abs() < 1e-8) return left;
  if (fRight.abs() < 1e-8) return right;
  for (var i = 0; i < 80; i++) {
    final mid = (left + right) / 2;
    final fMid = _polyEval(coeffs, mid);
    if (fMid.abs() < 1e-8) return mid;
    if ((fLeft < 0 && fMid > 0) || (fLeft > 0 && fMid < 0)) {
      right = mid;
      fRight = fMid;
    } else {
      left = mid;
      fLeft = fMid;
    }
  }
  return (left + right) / 2;
}

void _addUniqueRoot(List<double> roots, double value) {
  for (final r in roots) {
    if ((r - value).abs() < 1e-4) return;
  }
  roots.add(value);
}

List<double> _validateSolutions(Expr left, Expr right, List<double> solutions) {
  final valid = <double>[];
  for (final x in solutions) {
    final l = left.eval({'x': x});
    final r = right.eval({'x': x});
    if (l == null || r == null) continue;
    if ((l - r).abs() < 1e-6) {
      valid.add(x);
    }
  }
  valid.sort();
  return valid;
}

class _PolyN {
  final List<double> coeffs;
  final int maxDegree;

  const _PolyN(this.coeffs, this.maxDegree);

  double coeffAt(int degree) => degree < coeffs.length ? coeffs[degree] : 0;

  _PolyN add(_PolyN other) {
    final size = math.max(coeffs.length, other.coeffs.length);
    final res = List<double>.filled(size, 0);
    for (var i = 0; i < size; i++) {
      res[i] = (i < coeffs.length ? coeffs[i] : 0) + (i < other.coeffs.length ? other.coeffs[i] : 0);
    }
    return _PolyN(res, math.max(maxDegree, other.maxDegree));
  }

  _PolyN sub(_PolyN other) {
    final size = math.max(coeffs.length, other.coeffs.length);
    final res = List<double>.filled(size, 0);
    for (var i = 0; i < size; i++) {
      res[i] = (i < coeffs.length ? coeffs[i] : 0) - (i < other.coeffs.length ? other.coeffs[i] : 0);
    }
    return _PolyN(res, math.max(maxDegree, other.maxDegree));
  }

  _PolyN? mul(_PolyN other) {
    final deg = maxDegree + other.maxDegree;
    if (deg > 4) return null;
    final res = List<double>.filled(deg + 1, 0);
    for (var i = 0; i <= maxDegree; i++) {
      for (var j = 0; j <= other.maxDegree; j++) {
        res[i + j] += coeffAt(i) * other.coeffAt(j);
      }
    }
    return _PolyN(res, deg);
  }

  static _PolyN? fromExpr(Expr expr) {
    if (expr is Num) {
      return _PolyN([expr.value], 0);
    }
    if (expr is Const) {
      return _PolyN([expr.value], 0);
    }
    if (expr is Var && expr.name == 'x') {
      return _PolyN([0, 1], 1);
    }
    if (expr is Neg) {
      final inner = fromExpr(expr.value);
      if (inner == null) return null;
      final res = inner.coeffs.map((v) => -v).toList();
      return _PolyN(res, inner.maxDegree);
    }
    if (expr is Pow && expr.base is Var && (expr.base as Var).name == 'x' && expr.exp is Num) {
      final power = (expr.exp as Num).value;
      if (power % 1 == 0 && power >= 0 && power <= 4) {
        final deg = power.toInt();
        final res = List<double>.filled(deg + 1, 0);
        res[deg] = 1;
        return _PolyN(res, deg);
      }
    }
    if (expr is Add) {
      final l = fromExpr(expr.left);
      final r = fromExpr(expr.right);
      if (l == null || r == null) return null;
      return l.add(r);
    }
    if (expr is Sub) {
      final l = fromExpr(expr.left);
      final r = fromExpr(expr.right);
      if (l == null || r == null) return null;
      return l.sub(r);
    }
    if (expr is Mul) {
      final l = fromExpr(expr.left);
      final r = fromExpr(expr.right);
      if (l == null || r == null) return null;
      return l.mul(r);
    }
    if (expr is Div) {
      final l = fromExpr(expr.left);
      final r = fromExpr(expr.right);
      if (l == null || r == null) return null;
      if (r.maxDegree == 0 && r.coeffAt(0).abs() > 1e-9) {
        final scalar = r.coeffAt(0);
        final res = l.coeffs.map((v) => v / scalar).toList();
        return _PolyN(res, l.maxDegree);
      }
    }
    return null;
  }
}
