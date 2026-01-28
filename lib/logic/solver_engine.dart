// Fichier: lib/logic/solver_engine.dart

import 'ast_models.dart';
import 'solution_models.dart';
import 'rules/rules.dart';

typedef Rule = SolvingStep? Function(Expr input);

class SolverEngine {
  
  // L'ordre est CRUCIAL pour une résolution fluide.
  static final List<Rule> rules = [
    simplifyIdentity,
    simplifySqrt,
    simplifyUnaryMinus,
    simplifyPower,
    simplifyDistribute,
    
    // NOUVEAUX NOMS :
    simplifyRearrangeMultiply,    // Trie les multiplications
    simplifyTermMultiplication,
    simplifyVariableMultiplication,
    simplifyMultiplication,
    simplifyDivision,
    
    simplifyRearrangeAdd,         // Trie les additions ET soustractions
    simplifyCombineTerms,

    isolateVariable,                // <--- NOUVEAU : Isoler la variable
    
    simplifyAddition,
    simplifySubtraction,
  ];

  /// Point d'entrée : Résout une équation complète
  static Solution solve(Expr startEquation) {
    final List<SolvingStep> history = [];
    // On lance la simplification récursive
    final Expr finalResult = _simplify(startEquation, history);
    
    return Solution(
      steps: history,
      finalResult: finalResult,
    );
  }

  /// Moteur Récursif (Deep Simplification)
  /// 1. Simplifie les enfants d'abord (Post-Order Traversal)
  /// 2. Simplifie le nœud courant tant que possible
  static Expr _simplify(Expr expression, List<SolvingStep> history) {
    
    // --- ÉTAPE 1 : RÉCURSION (Plongée) ---
    // On nettoie d'abord ce qu'il y a à l'intérieur des parenthèses/opérations
    Expr current;
    if (expression is Add) {
      current = Add(_simplify(expression.left, history), _simplify(expression.right, history));
    } else if (expression is Sub) {
      current = Sub(_simplify(expression.left, history), _simplify(expression.right, history));
    } else if (expression is Mult) {
      current = Mult(_simplify(expression.left, history), _simplify(expression.right, history));
    } else if (expression is Div) {
      current = Div(_simplify(expression.numerator, history), _simplify(expression.denominator, history));
    } else if (expression is Power) {
       current = Power(_simplify(expression.left, history), _simplify(expression.right, history));
    } else if (expression is Sqrt) {
      current = Sqrt(_simplify(expression.value, history));
    } else if (expression is UnaryMinus) {
      current = UnaryMinus(_simplify(expression.value, history));
    } else if (expression is Equation) {
      current = Equation(_simplify(expression.left, history), _simplify(expression.right, history));
    }
    else {
      // Feuilles (Number, Variable)
      current = expression;
    }

    // --- ÉTAPE 2 : APPLICATION DES RÈGLES (Remontée) ---
    // On boucle tant qu'une règle modifie l'expression courante
    int loopSafety = 0; // Sécurité pour éviter les boucles infinies locales
    while (loopSafety < 100) {
      bool ruleApplied = false;
      for (final rule in rules) {
        final step = rule(current);
        if (step != null) {
          history.add(step);
          current = step.output;
          ruleApplied = true;
          break; // On recommence la liste des règles depuis le début (car l'arbre a changé)
        }
      }
      
      if (!ruleApplied) {
        break; // Plus rien à faire sur ce nœud, on remonte
      }
      loopSafety++;
    }
    
    return current;
  }
}
