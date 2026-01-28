// Fichier: lib/logic/standard_rules.dart
import 'dart:math' as math; 

import 'ast_models.dart';
import 'solution_models.dart';

// --- RÈGLE 1 : ADDITION ---
SolvingStep? simplifyAddition(Expr expression) {
  if (expression is Add && expression.left is Number && expression.right is Number) {
    final leftVal = (expression.left as Number).value;
    final rightVal = (expression.right as Number).value;
    final sum = leftVal + rightVal;
    
    return SolvingStep(
      input: expression,
      description: "Add the numbers ${_fmt(leftVal)} and ${_fmt(rightVal)}",
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
      description: "Subtract ${_fmt(rightVal)} from ${_fmt(leftVal)}",
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
      description: "Multiply ${_fmt(leftVal)} by ${_fmt(rightVal)}",
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

    if (denVal == 0) return null; // Sécurité

    final result = numVal / denVal;

    return SolvingStep(
      input: expression,
      description: "Divide ${_fmt(numVal)} by ${_fmt(denVal)}",
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
    
    // Calcul de la puissance
    final result = math.pow(leftVal, rightVal);

    return SolvingStep(
      input: expression,
      description: "Calculate the power ${_fmt(leftVal)} to the ${_fmt(rightVal)}",
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
    
    if (val < 0) return null; // Pas de nombres imaginaires pour l'instant

    final result = math.sqrt(val);

    return SolvingStep(
      input: expression,
      description: "Calculate the square root of ${_fmt(val)}",
      output: Number(result),
      changedPart: Number(result),
    );
  }
  return null;
}

// --- RÈGLE 7 : NÉGATIF (Simplification) ---
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


// --- UTILITAIRE DE FORMATAGE ---
String _fmt(double value) {
  if (value == value.toInt()) {
    return value.toInt().toString();
  }
  return value.toString();
}

// -----------------------------------------------------------------------
// LOGIQUE ALGÉBRIQUE (Le "Nettoyeur")
// -----------------------------------------------------------------------

/// Une structure simple pour analyser un terme : "3x", "x", "-5y"
class _Term {
  final double coefficient;
  final String? variable; // Null si c'est juste un nombre

  _Term(this.coefficient, this.variable);
}

/// Analyseur : Transforme une Expression brute en Concept (Coeff + Variable)
_Term? _extractTerm(Expr e) {
  // Cas 1 : Juste un nombre (5)
  if (e is Number) {
    return _Term(e.value, null);
  }
  // Cas 2 : Juste une variable (x) -> Coeff 1
  if (e is Variable) {
    return _Term(1.0, e.symbol);
  }
  // Cas 3 : Négatif (-x ou -5)
  if (e is UnaryMinus) {
    final subTerm = _extractTerm(e.value);
    if (subTerm != null) {
      return _Term(-subTerm.coefficient, subTerm.variable);
    }
  }
  // Cas 4 : Multiplication (2x ou 2*x)
  if (e is Mult) {
    // On suppose pour l'instant que le nombre est à gauche (Format standard)
    if (e.left is Number && e.right is Variable) {
      return _Term((e.left as Number).value, (e.right as Variable).symbol);
    }
    // Cas x*2 (Moins standard mais possible)
    if (e.left is Variable && e.right is Number) {
      return _Term((e.right as Number).value, (e.left as Variable).symbol);
    }
  }
  return null; // Trop complexe pour l'instant (ex: x^2, x*y)
}

/// RÈGLE 8 : REGROUPEMENT DES TERMES (Like Terms)
/// Transforme "2x + 3x" en "5x" et "x + x" en "2x"
SolvingStep? simplifyCombineTerms(Expr expression) {
  // On gère l'Addition (+) et la Soustraction (-)
  bool isAdd = expression is Add;
  bool isSub = expression is Sub;

  if (!isAdd && !isSub) return null;

  // On essaie d'extraire les infos des deux côtés
  Expr leftExpr = (expression is Add) ? expression.left : (expression as Sub).left;
  Expr rightExpr = (expression is Add) ? expression.right : (expression as Sub).right;

  final t1 = _extractTerm(leftExpr);
  final t2 = _extractTerm(rightExpr);

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
    // Ex: "Combine like terms (x)"
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

/// RÈGLE 9 : DISTRIBUTIVITÉ (Le "Brise-Glace")
/// Transforme "2 * (x + 3)" en "2x + 2*3"
SolvingStep? simplifyDistribute(Expr expression) {
  if (expression is Mult) {
    
    // Cas A : Nombre à Gauche -> 2 * (A + B)
    if (expression.left is Number && (expression.right is Add || expression.right is Sub)) {
      final factor = expression.left; // Le "2"
      final group = expression.right; // Le "(x + 3)"
      
      Expr newLeft, newRight;

      // On prépare la distribution
      if (group is Add) {
        newLeft = Mult(factor, group.left);  // 2 * x
        newRight = Mult(factor, group.right); // 2 * 3
      } else { // Sub
        newLeft = Mult(factor, (group as Sub).left);
        newRight = Mult(factor, (group as Sub).right);
      }

      // On recrée l'opération centrale (Add ou Sub)
      Expr resultNode;
      if (group is Add) {
        resultNode = Add(newLeft, newRight);
      } else {
        resultNode = Sub(newLeft, newRight);
      }

      return SolvingStep(
        input: expression,
        description: "Distribute ${_fmt((factor as Number).value)} into the parenthesis",
        output: resultNode,
        changedPart: resultNode,
      );
    }
    
    // TODO (Optionnel) : Cas Nombre à Droite -> (A + B) * 2
    // C'est le même principe inversé.
  }
  return null;
}

// -----------------------------------------------------------------------
// LOGIQUE DE TRI (Le "Rangement de Chambre")
// -----------------------------------------------------------------------

/// RÈGLE 10 : RÉORGANISATION (Reorder)
/// Transforme "2A + 10 + A" en "2A + A + 10" pour faciliter le calcul
SolvingStep? simplifyRearrange(Expr expression) {
  if (expression is! Add) return null;

  // 1. APLATIR : On récupère tous les morceaux de l'addition dans une liste
  // Ex: (2A + 10) + A  ->  [2A, 10, A]
  List<Expr> terms = _flattenAdditions(expression);

  // Si on a moins de 3 termes, pas besoin de trier (ou déjà géré par commutativité simple)
  if (terms.length < 2) return null;

  // 2. TRIER : On range (Variables d'abord, Nombres à la fin)
  // On crée une copie pour comparer après
  List<Expr> sortedTerms = List.from(terms);
  
  sortedTerms.sort((a, b) {
    int scoreA = _getPriorityScore(a);
    int scoreB = _getPriorityScore(b);
    return scoreB.compareTo(scoreA); // Score le plus haut en premier
  });

  // 3. VÉRIFIER : Est-ce que ça a changé quelque chose ?
  bool changed = false;
  for (int i = 0; i < terms.length; i++) {
    if (terms[i] != sortedTerms[i]) {
      changed = true;
      break;
    }
  }

  if (!changed) return null; // Déjà bien rangé

  // 4. RECONSTRUIRE : On recrée l'arbre d'addition propre
  // [2A, A, 10] -> ((2A + A) + 10)
  Expr newExpr = sortedTerms[0];
  for (int i = 1; i < sortedTerms.length; i++) {
    newExpr = Add(newExpr, sortedTerms[i]);
  }

  return SolvingStep(
    input: expression,
    description: "Reorder terms for easier calculation",
    output: newExpr,
    changedPart: newExpr,
  );
}

// --- Helpers pour le tri ---

// Récupère récursivement tous les termes d'une suite d'additions
List<Expr> _flattenAdditions(Expr e) {
  if (e is Add) {
    return [..._flattenAdditions(e.left), ..._flattenAdditions(e.right)];
  }
  return [e];
}

// Donne un score pour le tri : Variable (3) > Terme avec var (2) > Nombre (1)
int _getPriorityScore(Expr e) {
  if (e is Variable) return 3;
  if (e is Mult && (e.left is Variable || e.right is Variable)) return 2;
  if (e is Mult && (e.left is Number || e.right is Number)) return 2; // ex: 2A
  if (e is Number) return 1;
  return 0; // Autres
}

/// RÈGLE 11 : IDENTITÉ ET ZÉRO (Le Nettoyeur)
/// Gère : x * 1 = x, x * 0 = 0, x + 0 = x, x - 0 = x
SolvingStep? simplifyIdentity(Expr expression) {
  // 1. MULTIPLICATION
  if (expression is Mult) {
    if (expression.right is Number) {
      final val = (expression.right as Number).value;
      if (val == 1) { // x * 1 -> x
        return SolvingStep(
          input: expression,
          description: "Multiply by 1",
          output: expression.left,
          changedPart: expression.left,
        );
      }
      if (val == 0) { // x * 0 -> 0
        return SolvingStep(
          input: expression,
          description: "Multiply by 0",
          output: Number(0),
          changedPart: Number(0),
        );
      }
    }
  }

  // 2. ADDITION / SOUSTRACTION
  if (expression is Add || expression is Sub) {
    Expr right = (expression is Add) ? expression.right : (expression as Sub).right;
    Expr left = (expression is Add) ? expression.left : (expression as Sub).left;
    
    // x + 0 -> x
    if (right is Number && (right as Number).value == 0) {
      return SolvingStep(
        input: expression,
        description: "Remove zero",
        output: left,
        changedPart: left,
      );
    }
    // 0 + x -> x (Uniquement pour l'addition)
    if (expression is Add && left is Number && (left as Number).value == 0) {
      return SolvingStep(
        input: expression,
        description: "Remove zero",
        output: right,
        changedPart: right,
      );
    }
  }
  
  return null;
}

/// RÈGLE 12 : MULTIPLICATION DE TERMES (Advanced Multiply)
/// Gère : 5 * (-a) -> -5a
/// Gère : 2 * (3x) -> 6x
SolvingStep? simplifyTermMultiplication(Expr expression) {
  if (expression is Mult && expression.left is Number) {
    final double factor = (expression.left as Number).value;
    final Expr right = expression.right;

    // Cas A : 5 * (-x) -> -5x
    // Structure : Mult(Number, UnaryMinus(Var))
    if (right is UnaryMinus) {
      // On transforme 5 * (-x) en -(5 * x)
      // Le moteur repassera ensuite pour faire 5*x si besoin, ou laissera 5x
      final newExpr = UnaryMinus(Mult(expression.left, right.value));
      return SolvingStep(
        input: expression,
        description: "Extract negative sign",
        output: newExpr,
        changedPart: newExpr,
      );
    }

    // Cas B : 2 * (3x) -> 6x
    // Structure : Mult(Number, Mult(Number, Var))
    if (right is Mult && right.left is Number) {
      final double subFactor = (right.left as Number).value;
      final double newFactor = factor * subFactor;
      
      final newExpr = Mult(Number(newFactor), right.right);
      return SolvingStep(
        input: expression,
        description: "Multiply coefficients ${_fmt(factor)} and ${_fmt(subFactor)}",
        output: newExpr,
        changedPart: Number(newFactor),
      );
    }
  }
  return null;
}
