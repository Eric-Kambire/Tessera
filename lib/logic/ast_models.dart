// Fichier: lib/logic/ast_models.dart

sealed class Expr {
  const Expr();
  String toLatex();
}

// --- FEUILLES ---

class Number extends Expr {
  final double value;
  const Number(this.value);

  @override
  String toLatex() {
    if (value == value.toInt()) return value.toInt().toString();
    return value.toString();
  }
}

class Variable extends Expr {
  final String symbol;
  const Variable(this.symbol);

  @override
  String toLatex() => symbol;
}

// --- NOUVEAU : NOMBRES NÉGATIFS ---
class UnaryMinus extends Expr {
  final Expr value;
  const UnaryMinus(this.value);

  @override
  String toLatex() => "-${value.toLatex()}";
}

// --- NOUVEAU : RACINES ---
class Sqrt extends Expr {
  final Expr value;
  const Sqrt(this.value);

  @override
  String toLatex() => "\\sqrt{${value.toLatex()}}";
}

// --- OPÉRATIONS ---

class Add extends Expr {
  final Expr left;
  final Expr right;
  const Add(this.left, this.right);

  @override
  String toLatex() {
    String r = right.toLatex();
    // RIGUEUR : Si le terme de droite est négatif (ex: -5), on met des parenthèses
    // Ex: 4 + (-5)
    if (_isNegative(right)) {
      r = "\\left($r\\right)";
    }
    return "${left.toLatex()} + $r";
  }
}

class Sub extends Expr {
  final Expr left;
  final Expr right;
  const Sub(this.left, this.right);

  @override
  String toLatex() {
    String r = right.toLatex();
    // RIGUEUR : 4 - (-5)
    if (_isNegative(right)) {
      r = "\\left($r\\right)";
    }
    return "${left.toLatex()} - $r";
  }
}

class Mult extends Expr {
  final Expr left;
  final Expr right;
  const Mult(this.left, this.right);

  @override
  String toLatex() {
    String l = (left is Add || left is Sub) ? "\\left(${left.toLatex()})\\right)" : left.toLatex();
    String r = right.toLatex();

    // 1. Gestion RIGUEUREUSE des négatifs (Prioritaire)
    if (_isNegative(right)) {
      r = "\\left($r\\right)";
    } 
    // 2. Gestion de la priorité (ex: 2 * (x+1))
    else if (right is Add || right is Sub) {
      r = "\\left($r\\right)";
    }

    // 3. TOUCHE ESTHÉTIQUE : Multiplication implicite visuelle
    // Si on a "Nombre * Variable" (2x) ou "Variable * Variable" (xy) -> Pas de point
    bool isImplicitLike = (left is Number && right is Variable) || 
                          (left is Number && right is Sqrt) ||
                          (left is Variable && right is Variable);

    if (isImplicitLike) {
      return "$l$r"; // Collé (2x)
    }

    return "$l \\cdot $r"; // Point (2 \cdot 3)
  }
}

class Div extends Expr {
  final Expr numerator;
  final Expr denominator;
  const Div(this.numerator, this.denominator);

  @override
  String toLatex() => "\\frac{${numerator.toLatex()}}{${denominator.toLatex()}}";
}

class Power extends Expr {
  final Expr left;
  final Expr right;
  const Power(this.left, this.right);

  @override
  String toLatex() {
    String l = left.toLatex();
    // Si la base est négative, il faut des parenthèses : (-2)^3
    if (left is UnaryMinus || (left is Number && (left as Number).value < 0)) {
      l = "\\left($l\\right)";
    }
    return "{$l}^{${right.toLatex()}}";
  }
}

class Equation extends Expr {
  final Expr left;
  final Expr right;
  const Equation(this.left, this.right);

  @override
  String toLatex() => "${left.toLatex()} = ${right.toLatex()}";
}

// --- HELPER DE RIGUEUR ---
// Vérifie si une expression est visuellement négative
bool _isNegative(Expr e) {
  if (e is UnaryMinus) return true;
  if (e is Number && e.value < 0) return true;
  return false;
}
