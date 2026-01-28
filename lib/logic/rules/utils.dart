import '../ast_models.dart';

// --- UTILITAIRE DE FORMATAGE ---
String fmt(double value) {
  if (value == value.toInt()) {
    return value.toInt().toString();
  }
  return value.toString();
}

/// Une structure simple pour analyser un terme : "3x", "x", "-5y"
class Term {
  final double coefficient;
  final String? variable; // Null si c'est juste un nombre

  Term(this.coefficient, this.variable);
}

/// Analyseur : Transforme une Expression brute en Concept (Coeff + Variable)
Term? extractTerm(Expr e) {
  // Cas 1 : Juste un nombre (5)
  if (e is Number) {
    return Term(e.value, null);
  }
  // Cas 2 : Juste une variable (x) -> Coeff 1
  if (e is Variable) {
    return Term(1.0, e.symbol);
  }
  // Cas 3 : Négatif (-x ou -5)
  if (e is UnaryMinus) {
    final subTerm = extractTerm(e.value);
    if (subTerm != null) {
      return Term(-subTerm.coefficient, subTerm.variable);
    }
  }
  // Cas 4 : Multiplication (2x ou 2*x)
  if (e is Mult) {
    // On suppose pour l'instant que le nombre est à gauche (Format standard)
    if (e.left is Number && e.right is Variable) {
      return Term((e.left as Number).value, (e.right as Variable).symbol);
    }
    // Cas x*2 (Moins standard mais possible)
    if (e.left is Variable && e.right is Number) {
      return Term((e.right as Number).value, (e.left as Variable).symbol);
    }
  }
  return null; // Trop complexe pour l'instant (ex: x^2, x*y)
}

// Récupère récursivement tous les termes d'une suite d'additions
List<Expr> flattenAdditions(Expr e) {
  if (e is Add) {
    return [...flattenAdditions(e.left), ...flattenAdditions(e.right)];
  }
  return [e];
}

// Donne un score pour le tri : Variable (3) > Terme avec var (2) > Nombre (1)
int getPriorityScore(Expr e) {
  if (e is Variable) return 3;
  if (e is Mult && (e.left is Variable || e.right is Variable)) return 2;
  if (e is Mult && (e.left is Number || e.right is Number)) return 2; // ex: 2A
  if (e is Number) return 1;
  return 0; // Autres
}
