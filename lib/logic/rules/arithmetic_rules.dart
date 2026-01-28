
import 'dart:math' as math;
import '../ast_models.dart';
import '../solution_models.dart';
import 'utils.dart';

// --- RÈGLE 1 : ADDITION ---
SolvingStep? simplifyAddition(Expr expression) {
  if (expression is Add && expression.left is Number && expression.right is Number) {
    final leftVal = (expression.left as Number).value;
    final rightVal = (expression.right as Number).value;
    final sum = leftVal + rightVal;
    
    return SolvingStep(
      input: expression,
      description: "Add the numbers \${fmt(leftVal)} and \${fmt(rightVal)}",
      output: Number(sum),
      changedPart: Number(sum),
    );
  }
  return null;
}

// --- RÈGLE 2 : SOUSTRACTION ---
SolvingStep? simplifySubtraction(Expr expression) {
  if (expression is Sub && expression.left is Number && expression.right is Number) {
    final leftVal = (expression.left as Number).value;
    final rightVal = (expression.right as Number).value;
    final result = leftVal - rightVal;

    return SolvingStep(
      input: expression,
      description: "Subtract \${fmt(rightVal)} from \${fmt(leftVal)}",
      output: Number(result),
      changedPart: Number(result),
    );
  }
  return null;
}

// --- RÈGLE 3 : MULTIPLICATION ---
SolvingStep? simplifyMultiplication(Expr expression) {
  if (expression is Mult && expression.left is Number && expression.right is Number) {
    final leftVal = (expression.left as Number).value;
    final rightVal = (expression.right as Number).value;
    final result = leftVal * rightVal;

    return SolvingStep(
      input: expression,
      description: "Multiply \${fmt(leftVal)} by \${fmt(rightVal)}",
      output: Number(result),
      changedPart: Number(result),
    );
  }
  return null;
}

// --- RÈGLE 4 : DIVISION ---
SolvingStep? simplifyDivision(Expr expression) {
  if (expression is Div && expression.numerator is Number && expression.denominator is Number) {
    final numVal = (expression.numerator as Number).value;
    final denVal = (expression.denominator as Number).value;

    if (denVal == 0) return null; // Sécurité division par zéro

    final result = numVal / denVal;

    return SolvingStep(
      input: expression,
      description: "Divide \${fmt(numVal)} by \${fmt(denVal)}",
      output: Number(result),
      changedPart: Number(result),
    );
  }
  return null;
}

// --- RÈGLE 5 : PUISSANCE ---
SolvingStep? simplifyPower(Expr expression) {
  if (expression is Power && expression.left is Number && expression.right is Number) {
    final leftVal = (expression.left as Number).value;
    final rightVal = (expression.right as Number).value;
    
    final result = math.pow(leftVal, rightVal);

    return SolvingStep(
      input: expression,
      description: "Calculate the power \${fmt(leftVal)} to the \${fmt(rightVal)}",
      output: Number(result.toDouble()),
      changedPart: Number(result.toDouble()),
    );
  }
  return null;
}

// --- RÈGLE 6 : RACINE CARRÉE ---
SolvingStep? simplifySqrt(Expr expression) {
  if (expression is Sqrt && expression.value is Number) {
    final val = (expression.value as Number).value;
    
    if (val < 0) return null; 

    final result = math.sqrt(val);

    return SolvingStep(
      input: expression,
      description: "Calculate the square root of \${fmt(val)}",
      output: Number(result),
      changedPart: Number(result),
    );
  }
  return null;
}
