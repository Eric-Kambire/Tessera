import '../ast_models.dart';
import '../solution_models.dart';
import 'utils.dart';

/// RÈGLE : RÉORGANISATION (Reorder)
/// Transforme "2A + 10 + A" en "2A + A + 10" pour faciliter le calcul
SolvingStep? simplifyRearrange(Expr expression) {
  if (expression is! Add) return null;

  // 1. APLATIR : On récupère tous les morceaux de l'addition dans une liste
  List<Expr> terms = flattenAdditions(expression);

  // Si on a moins de 3 termes, pas besoin de trier
  if (terms.length < 2) return null;

  // 2. TRIER : On range (Variables d'abord, Nombres à la fin)
  List<Expr> sortedTerms = List.from(terms);
  
  sortedTerms.sort((a, b) {
    int scoreA = getPriorityScore(a);
    int scoreB = getPriorityScore(b);
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
