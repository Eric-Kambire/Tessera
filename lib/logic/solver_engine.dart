// Fichier: lib/logic/solver_engine.dart

import 'ast_models.dart';
import 'solution_models.dart';
import 'standard_rules.dart';

typedef Rule = SolvingStep? Function(Expr input);

class SolverEngine {
  
  static final List<Rule> rules = [
    simplifyIdentity,     // <--- NOUVEAU (Le Nettoyeur passe en premier pour alléger)
    simplifySqrt,
    simplifyUnaryMinus,
    simplifyPower,
    simplifyDistribute,
    
    simplifyTermMultiplication, // <--- NOUVEAU (Pour gérer 5 * -a)
    simplifyMultiplication,     // (Pour gérer 5 * 5)
    simplifyDivision,
    
    simplifyRearrange,    
    simplifyCombineTerms, 
    
    simplifyAddition,
    simplifySubtraction,
  ];

  /// Résout une équation en appliquant les règles de manière récursive.
  static Solution solve(Expr startEquation) {
    final List<SolvingStep> history = [];
    final Expr finalResult = _simplify(startEquation, history);
    
    return Solution(
      steps: history,
      finalResult: finalResult,
    );
  }

  /// Le vrai moteur : une fonction récursive qui simplifie un nœud d'expression.
  static Expr _simplify(Expr expression, List<SolvingStep> history) {
    
    // 1. ÉTAPE RÉCURSIVE : Simplifier les enfants de ce nœud d'abord.
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
      current = expression;
    }

    // 2. ÉTAPE D'APPLICATION : Appliquer les règles sur le nœud actuel.
    while (true) {
      bool ruleApplied = false;
      for (final rule in rules) {
        final step = rule(current);
        if (step != null) {
          history.add(step);
          current = step.output;
          ruleApplied = true;
          break;
        }
      }
      if (!ruleApplied) {
        break;
      }
    }
    
    return current;
  }
}
