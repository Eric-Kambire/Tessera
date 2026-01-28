import '../ast_models.dart';
import '../solution_models.dart';

/// RÈGLE : ISOLEMENT DE VARIABLE
/// Gère le déplacement de termes d'un côté à l'autre d'une équation.
/// Exemple : x + 2 = 5  ->  x = 5 - 2
SolvingStep? isolateVariable(Expr expression) {
  if (expression is Equation) {
    final left = expression.left;
    final right = expression.right;

    // Cas 1 : Isoler depuis la gauche (ex: x + 2 = 5)
    if (left is Add && left.right is Number) {
      final newRight = Sub(right, left.right);
      final newLeft = left.left;
      final newEq = Equation(newLeft, newRight);

      return SolvingStep(
        input: expression,
        description: "Move term to the other side",
        output: newEq,
        changedPart: newEq,
      );
    }

    // Cas 2 : Isoler depuis la droite (ex: 5 = x + 2)
    if (right is Add && right.right is Number) {
      final newLeft = Sub(left, right.right);
      final newRight = right.left;
      final newEq = Equation(newLeft, newRight);

      return SolvingStep(
        input: expression,
        description: "Move term to the other side",
        output: newEq,
        changedPart: newEq,
      );
    }
  }
  return null;
}
