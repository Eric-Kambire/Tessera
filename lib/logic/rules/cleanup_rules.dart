import '../ast_models.dart';
import '../solution_models.dart';

/// RÈGLE : NÉGATIF (Simplification)
SolvingStep? simplifyUnaryMinus(Expr expression) {
  if (expression is UnaryMinus && expression.value is Number) {
    final val = (expression.value as Number).value;
    return SolvingStep(
      input: expression,
      description: "Negate the number",
      output: Number(-val),
      changedPart: Number(-val),
    );
  }
  return null;
}

/// RÈGLE : IDENTITÉ ET ZÉRO (CORRIGÉE)
/// Gère : x * 1, 1 * x, x * 0, 0 * x, x + 0, 0 + x
SolvingStep? simplifyIdentity(Expr expression) {
  // 1. MULTIPLICATION
  if (expression is Mult) {
    // Cas A : Zéro à gauche ou à droite (0 * x ou x * 0) -> 0
    if ((expression.left is Number && (expression.left as Number).value == 0) ||
        (expression.right is Number && (expression.right as Number).value == 0)) {
      return SolvingStep(
        input: expression,
        description: "Multiply by 0",
        output: Number(0),
        changedPart: Number(0),
      );
    }

    // Cas B : Un à gauche (1 * x) -> x
    if (expression.left is Number && (expression.left as Number).value == 1) {
      return SolvingStep(
        input: expression,
        description: "Multiply by 1",
        output: expression.right,
        changedPart: expression.right,
      );
    }
    
    // Cas C : Un à droite (x * 1) -> x
    if (expression.right is Number && (expression.right as Number).value == 1) {
      return SolvingStep(
        input: expression,
        description: "Multiply by 1",
        output: expression.left,
        changedPart: expression.left,
      );
    }
  }

  // 2. ADDITION / SOUSTRACTION
  if (expression is Add || expression is Sub) {
    Expr? left = (expression is Add || expression is Sub) ? (expression as dynamic).left : null;
    Expr? right = (expression is Add || expression is Sub) ? (expression as dynamic).right : null;
    
    // x + 0 -> x
    if (right is Number && right.value == 0) {
      return SolvingStep(
        input: expression,
        description: "Remove zero",
        output: left!,
        changedPart: left,
      );
    }
    // 0 + x -> x (Uniquement pour l'addition)
    if (expression is Add && left is Number && left.value == 0) {
      return SolvingStep(
        input: expression,
        description: "Remove zero",
        output: right!,
        changedPart: right,
      );
    }
  }
  
  return null;
}
