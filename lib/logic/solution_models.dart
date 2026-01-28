// Fichier: lib/logic/solution_models.dart

import 'ast_models.dart'; // On a besoin des briques qu'on vient de créer

/// Une étape de résolution respectant le format IDO (Input-Description-Output)
class SolvingStep {
  final Expr input;         // L'état avant (ex: 2x = 10)
  final String description; // L'explication (ex: "Diviser les deux côtés par 2")
  final Expr output;        // L'état après (ex: x = 5)

  // Optionnel : Pour la coloration future (Règle "Coloring" de Photomath)
  // Permettra de surligner en bleu ce qui a changé.
  final Expr? changedPart; 

  SolvingStep({
    required this.input,
    required this.description,
    required this.output,
    this.changedPart,
  });
}

/// La Solution complète qui sera envoyée à l'interface
class Solution {
  // 1. Les étapes de calcul (Solving Steps)
  final List<SolvingStep> steps;

  // 2. La réponse finale (Solution Step - encadré rouge)
  final Expr finalResult;

  Solution({
    required this.steps,
    required this.finalResult,
  });
}
