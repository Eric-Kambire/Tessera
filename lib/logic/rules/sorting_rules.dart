import '../ast_models.dart';
import '../solution_models.dart';
import 'utils.dart';

/// RÈGLE : TRIEUR ADDITION/SOUSTRACTION (Version V2)
/// Transforme : a - 1 + 2a en 3a - 1
SolvingStep? simplifyRearrangeAdd(Expr expression) {
  // Accepte Add ET Sub !
  if (expression is! Add && expression is! Sub) return null;

  List<Expr> terms = flattenAdd(expression);
  if (terms.length < 2) return null;

  // Tri
  List<Expr> sortedTerms = List.from(terms);
  sortedTerms.sort((a, b) => getPriorityScore(b).compareTo(getPriorityScore(a)));

  // Vérif changement
  bool changed = false;
  for (int i = 0; i < terms.length; i++) {
    // Comparaison basique via Latex pour simplifier
    if (terms[i].toLatex() != sortedTerms[i].toLatex()) {
      changed = true;
      break;
    }
  }
  if (!changed) return null;

  // Reconstruction propre (avec des Sub si négatif)
  Expr newExpr = sortedTerms[0];
  for (int i = 1; i < sortedTerms.length; i++) {
    Expr t = sortedTerms[i];
    if (t is UnaryMinus) {
       newExpr = Sub(newExpr, t.value);
    } else if (t is Number && t.value < 0) {
       newExpr = Sub(newExpr, Number(-t.value));
    } else {
       newExpr = Add(newExpr, t);
    }
  }

  return SolvingStep(
    input: expression,
    description: "Reorder terms",
    output: newExpr,
    changedPart: newExpr,
  );
}

/// RÈGLE : REGROUPEMENT MULTIPLICATION (Trieur 5*x*2 -> 10x)
SolvingStep? simplifyRearrangeMultiply(Expr expression) {
  if (expression is! Mult) return null;

  List<Expr> factors = flattenMult(expression);
  if (factors.length < 2) return null;

  double coeff = 1.0;
  List<Expr> vars = [];
  
  for (var f in factors) {
    if (f is Number) coeff *= f.value;
    else if (f is UnaryMinus && f.value is Number) coeff *= -(f.value as Number).value;
    else vars.add(f);
  }

  if (coeff == 0) return SolvingStep(input: expression, description: "Multiply by 0", output: Number(0), changedPart: Number(0));

  vars.sort((a, b) => a.toLatex().compareTo(b.toLatex()));

  Expr? newExpr;
  if (vars.isNotEmpty) {
    newExpr = vars.last;
    for (int i = vars.length - 2; i >= 0; i--) newExpr = Mult(vars[i], newExpr!);
  }

  if (coeff != 1.0 || newExpr == null) {
    if (newExpr == null) newExpr = Number(coeff);
    else {
      if (coeff == -1.0) newExpr = UnaryMinus(newExpr);
      else newExpr = Mult(Number(coeff), newExpr);
    }
  }

  if (newExpr!.toLatex() != expression.toLatex()) {
     return SolvingStep(input: expression, description: "Simplify multiplication", output: newExpr, changedPart: newExpr);
  }
  return null;
}
