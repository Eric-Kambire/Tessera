import '../ast_models.dart';

// Formattage propre (5.0 -> "5")
String fmt(double value) {
  if (value == value.toInt()) return value.toInt().toString();
  return value.toString();
}

// Structure d'analyse
class Term {
  final double coefficient;
  final String? variable;
  Term(this.coefficient, this.variable);
}

// Extraction intelligente (gère 2x, x, -x, -5)
Term? extractTerm(Expr e) {
  if (e is Number) return Term(e.value, null);
  if (e is Variable) return Term(1.0, e.symbol);
  if (e is UnaryMinus) {
    final sub = extractTerm(e.value);
    return sub != null ? Term(-sub.coefficient, sub.variable) : null;
  }
  if (e is Mult) {
    if (e.left is Number && e.right is Variable) return Term((e.left as Number).value, (e.right as Variable).symbol);
    if (e.left is Variable && e.right is Number) return Term((e.right as Number).value, (e.left as Variable).symbol);
  }
  return null;
}

// Score pour le tri (Puissances > Variables > Nombres)
int getPriorityScore(Expr e) {
  if (e is Power) return 3;
  if (e is Variable) return 2;
  if (e is Mult && (e.left is Variable || e.right is Variable)) return 2;
  if (e is Mult && (e.left is Number || e.right is Number)) return 2;
  if (e is Number) return 1;
  return 0;
}

// Aplatisseur universel (Additions ET Soustractions)
List<Expr> flattenAdd(Expr e) {
  if (e is Add) return [...flattenAdd(e.left), ...flattenAdd(e.right)];
  if (e is Sub) {
    // Transforme a - b en [a, -b]
    List<Expr> rightTerms = flattenAdd(e.right).map((t) => negateTerm(t)).toList();
    return [...flattenAdd(e.left), ...rightTerms];
  }
  return [e];
}

// Aplatisseur de multiplication
List<Expr> flattenMult(Expr e) {
  if (e is Mult) return [...flattenMult(e.left), ...flattenMult(e.right)];
  return [e];
}

// Helper pour inverser un signe
Expr negateTerm(Expr e) {
  if (e is Number) return Number(-e.value);
  if (e is UnaryMinus) return e.value; // --a -> a
  return UnaryMinus(e);
}
