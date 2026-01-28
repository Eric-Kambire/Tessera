import '../ast_models.dart';
import '../solution_models.dart';

SolvingStep? simplifyUnaryMinus(Expr expression) {
  if (expression is UnaryMinus && expression.value is Number) {
    return SolvingStep(input: expression, description: "Negate", output: Number(-(expression.value as Number).value), changedPart: Number(0));
  }
  return null;
}

/// RÈGLE : IDENTITÉ ET ZÉRO (Version V2)
SolvingStep? simplifyIdentity(Expr expression) {
  if (expression is Mult) {
    if ((expression.left is Number && (expression.left as Number).value == 0) ||
        (expression.right is Number && (expression.right as Number).value == 0)) {
      return SolvingStep(input: expression, description: "Multiply by 0", output: Number(0), changedPart: Number(0));
    }
    if (expression.left is Number && (expression.left as Number).value == 1) {
      return SolvingStep(input: expression, description: "Multiply by 1", output: expression.right, changedPart: expression.right);
    }
    if (expression.right is Number && (expression.right as Number).value == 1) {
      return SolvingStep(input: expression, description: "Multiply by 1", output: expression.left, changedPart: expression.left);
    }
  }
  if (expression is Add) {
    if (expression.right is Number && (expression.right as Number).value == 0) return SolvingStep(input: expression, description: "Remove 0", output: expression.left, changedPart: expression.left);
    if (expression.left is Number && (expression.left as Number).value == 0) return SolvingStep(input: expression, description: "Remove 0", output: expression.right, changedPart: expression.right);
  }
  if (expression is Sub) {
    if (expression.right is Number && (expression.right as Number).value == 0) return SolvingStep(input: expression, description: "Remove 0", output: expression.left, changedPart: expression.left);
  }
  return null;
}
