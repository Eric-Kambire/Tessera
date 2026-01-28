import '../ast_models.dart';
import '../solution_models.dart';
import 'utils.dart';

/// RÈGLE : REGROUPEMENT DES TERMES (Like Terms)
/// Transforme "2x + 3x" en "5x" et "x + x" en "2x"
SolvingStep? simplifyCombineTerms(Expr expression) {
  // On gère l'Addition (+) et la Soustraction (-)
  bool isAdd = expression is Add;
  bool isSub = expression is Sub;

  if (!isAdd && !isSub) return null;

  // On essaie d'extraire les infos des deux côtés
  Expr leftExpr = (expression is Add) ? expression.left : (expression as Sub).left;
  Expr rightExpr = (expression is Add) ? expression.right : (expression as Sub).right;

  final t1 = extractTerm(leftExpr);
  final t2 = extractTerm(rightExpr);

  // Si on a réussi à analyser les deux ET qu'ils ont la même variable (x avec x, ou nombre avec nombre)
  if (t1 != null && t2 != null && t1.variable == t2.variable) {
    
    // Calcul du nouveau coefficient
    double newCoeff;
    if (isAdd) {
      newCoeff = t1.coefficient + t2.coefficient; // 2 + 3
    } else {
      newCoeff = t1.coefficient - t2.coefficient; // 2 - 3
    }

    // Création du résultat
    Expr resultNode;
    if (t1.variable == null) {
      // C'était juste des nombres : 2 + 3 = 5
      resultNode = Number(newCoeff);
    } else {
      // C'était des variables : 2x + 3x = 5x
      if (newCoeff == 0) {
        resultNode = Number(0); // 2x - 2x = 0
      } else if (newCoeff == 1) {
        resultNode = Variable(t1.variable!); // 1x -> x
      } else if (newCoeff == -1) {
        resultNode = UnaryMinus(Variable(t1.variable!)); // -1x -> -x
      } else {
        resultNode = Mult(Number(newCoeff), Variable(t1.variable!)); // 5x
      }
    }

    // Construction de la phrase explicative
    String varName = t1.variable ?? "numbers";
    String desc = "Combine like terms ($varName)"; 

    return SolvingStep(
      input: expression,
      description: desc,
      output: resultNode,
      changedPart: resultNode,
    );
  }

  return null;
}

/// RÈGLE : DISTRIBUTIVITÉ UNIVERSELLE
/// Gère : 2 * (x + 1) -> 2x + 2
/// Gère aussi : a * (2a - 1) -> a*2a - a
SolvingStep? simplifyDistribute(Expr expression) {
  if (expression is Mult) {
    Expr factor = expression.left;
    Expr group = expression.right;

    // On vérifie si la droite est une parenthèse (Addition ou Soustraction)
    bool isGroup = group is Add || group is Sub;

    // NOUVEAU : On accepte les Nombres, les Variables, ou les Négatifs (ex: -a)
    bool isSimpleFactor = factor is Number || factor is Variable || factor is UnaryMinus;

    if (isSimpleFactor && isGroup) {
      Expr newLeft, newRight;
      
      // Distribution : Facteur * Gauche
      newLeft = Mult(factor, (group is Add ? group.left : (group as Sub).left));
      
      // Distribution : Facteur * Droite
      newRight = Mult(factor, (group is Add ? group.right : (group as Sub).right));

      // On recrée l'opération centrale
      Expr resultNode;
      if (group is Add) {
        resultNode = Add(newLeft, newRight);
      } else {
        resultNode = Sub(newLeft, newRight);
      }

      return SolvingStep(
        input: expression,
        description: "Distribute term into parenthesis",
        output: resultNode,
        changedPart: resultNode,
      );
    }
  }
  return null;
}

/// RÈGLE : MULTIPLICATION DE TERMES (Advanced Multiply)
/// Gère : 5 * (-a) -> -5a
/// Gère : 2 * (3x) -> 6x
SolvingStep? simplifyTermMultiplication(Expr expression) {
  if (expression is Mult && expression.left is Number) {
    final double factor = (expression.left as Number).value;
    final Expr right = expression.right;

    // Cas A : 5 * (-x) -> -5x
    if (right is UnaryMinus) {
      final newExpr = UnaryMinus(Mult(expression.left, right.value));
      return SolvingStep(
        input: expression,
        description: "Extract negative sign",
        output: newExpr,
        changedPart: newExpr,
      );
    }

    // Cas B : 2 * (3x) -> 6x
    if (right is Mult && right.left is Number) {
      final double subFactor = (right.left as Number).value;
      final double newFactor = factor * subFactor;
      
      final newExpr = Mult(Number(newFactor), right.right);
      return SolvingStep(
        input: expression,
        description: "Multiply coefficients \${fmt(factor)} and \${fmt(subFactor)}",
        output: newExpr,
        changedPart: Number(newFactor),
      );
    }
  }
  return null;
}

/// RÈGLE : MULTIPLICATION DE VARIABLES
/// Gère : x * x -> x^2
/// Gère : a * (2a) -> 2a^2
SolvingStep? simplifyVariableMultiplication(Expr expression) {
  if (expression is Mult && expression.left is Variable) {
    final leftVar = (expression.left as Variable).symbol;
    final right = expression.right;

    // Cas 1 : a * a -> a^2
    if (right is Variable && right.symbol == leftVar) {
      final newVal = Power(expression.left, Number(2));
      return SolvingStep(
        input: expression, 
        description: "Multiply $leftVar by itself", 
        output: newVal, 
        changedPart: newVal
      );
    }

    // Cas 2 : a * (2a) -> 2a^2
    if (right is Mult && right.left is Number && right.right is Variable) {
      if ((right.right as Variable).symbol == leftVar) {
        final newPower = Power(expression.left, Number(2));
        final newVal = Mult(right.left, newPower);
        return SolvingStep(
          input: expression, 
          description: "Combine $leftVar terms", 
          output: newVal, 
          changedPart: newVal
        );
      }
    }
  }
  return null;
}
