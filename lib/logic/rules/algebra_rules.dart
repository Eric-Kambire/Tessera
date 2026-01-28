import '../ast_models.dart';
import '../solution_models.dart';
import 'utils.dart';

/// RÈGLE : REGROUPEMENT DES TERMES (2x + 3x -> 5x)
SolvingStep? simplifyCombineTerms(Expr expression) {
  bool isAdd = expression is Add;
  bool isSub = expression is Sub;
  if (!isAdd && !isSub) return null;

  // CAST EXPLICITE : On dit à Dart "T'inquiète, je sais que c'est un Add ou un Sub"
  Expr left = (isAdd) ? (expression as Add).left : (expression as Sub).left;
  Expr right = (isAdd) ? (expression as Add).right : (expression as Sub).right;

  final t1 = extractTerm(left);
  final t2 = extractTerm(right);

  if (t1 != null && t2 != null && t1.variable == t2.variable) {
    double newCoeff = isAdd ? t1.coefficient + t2.coefficient : t1.coefficient - t2.coefficient;
    Expr result;
    if (t1.variable == null) result = Number(newCoeff);
    else if (newCoeff == 0) result = Number(0);
    else if (newCoeff == 1) result = Variable(t1.variable!);
    else if (newCoeff == -1) result = UnaryMinus(Variable(t1.variable!));
    else result = Mult(Number(newCoeff), Variable(t1.variable!));

    return SolvingStep(input: expression, description: "Combine like terms", output: result, changedPart: result);
  }
  return null;
}

/// RÈGLE : DISTRIBUTIVITÉ UNIVERSELLE
SolvingStep? simplifyDistribute(Expr expression) {
  if (expression is Mult) {
    Expr factor = expression.left;
    Expr group = expression.right;
    bool isGroup = group is Add || group is Sub;
    bool isSimple = factor is Number || factor is Variable || factor is UnaryMinus;

    if (isSimple && isGroup) {
      // CORRECTION ICI : On caste group en (Add) ou (Sub) avant d'accéder à .left
      Expr groupLeft = (group is Add) ? (group as Add).left : (group as Sub).left;
      Expr groupRight = (group is Add) ? (group as Add).right : (group as Sub).right;

      Expr newLeft = Mult(factor, groupLeft);
      Expr newRight = Mult(factor, groupRight);
      
      Expr resultNode = (group is Add) ? Add(newLeft, newRight) : Sub(newLeft, newRight);
      return SolvingStep(input: expression, description: "Distribute", output: resultNode, changedPart: resultNode);
    }
  }
  return null;
}

/// RÈGLE : MULTIPLICATION DE TERMES (5 * -a -> -5a)
SolvingStep? simplifyTermMultiplication(Expr expression) {
  if (expression is Mult && expression.left is Number) {
    final double factor = (expression.left as Number).value;
    final Expr right = expression.right;

    if (right is UnaryMinus) {
      final newExpr = UnaryMinus(Mult(expression.left, right.value));
      return SolvingStep(input: expression, description: "Extract sign", output: newExpr, changedPart: newExpr);
    }
    // CORRECTION : On vérifie et on caste proprement
    if (right is Mult && right.left is Number) {
      final double subFactor = (right.left as Number).value;
      final newExpr = Mult(Number(factor * subFactor), right.right);
      return SolvingStep(input: expression, description: "Multiply coefficients", output: newExpr, changedPart: newExpr);
    }
  }
  return null;
}

/// RÈGLE : FUSION VARIABLES (a * a -> a^2)
SolvingStep? simplifyVariableMultiplication(Expr expression) {
  if (expression is Mult) {
    if (expression.left is Variable && expression.right is Variable) {
      if ((expression.left as Variable).symbol == (expression.right as Variable).symbol) {
        final newVal = Power(expression.left, Number(2));
        return SolvingStep(input: expression, description: "Square variable", output: newVal, changedPart: newVal);
      }
    }
    
    // Gère le cas imbriqué (a * (a * b))
    // CORRECTION : On crée une variable locale 'right' typée
    final rightNode = expression.right; 
    
    if (expression.left is Variable && rightNode is Mult && rightNode.left is Variable) {
      // Maintenant Dart sait que rightNode est un Mult
      if ((expression.left as Variable).symbol == (rightNode.left as Variable).symbol) {
         final newPower = Power(expression.left, Number(2));
         final newVal = Mult(newPower, rightNode.right);
         return SolvingStep(input: expression, description: "Combine variables", output: newVal, changedPart: newVal);
      }
    }
  }
  return null;
}
