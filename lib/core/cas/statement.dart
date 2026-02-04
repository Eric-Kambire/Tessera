import 'expr.dart';

enum RelOp {
  eq,
  lt,
  le,
  gt,
  ge,
}

abstract class Statement {
  const Statement();
}

class Equation extends Statement {
  final Expr left;
  final Expr right;

  const Equation(this.left, this.right);
}

class Inequality extends Statement {
  final Expr left;
  final Expr right;
  final RelOp op;

  const Inequality(this.left, this.right, this.op);
}

String relOpToString(RelOp op) {
  switch (op) {
    case RelOp.eq:
      return '=';
    case RelOp.lt:
      return '<';
    case RelOp.le:
      return '<=';
    case RelOp.gt:
      return '>';
    case RelOp.ge:
      return '>=';
  }
}
