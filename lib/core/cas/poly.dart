class Poly {
  final double a;
  final double b;
  final double c;

  const Poly(this.a, this.b, this.c);

  factory Poly.constant(double c) => Poly(0, 0, c);
  factory Poly.linear(double a, double b) => Poly(0, a, b);

  bool get isConstant => a.abs() < 1e-9 && b.abs() < 1e-9;
  double get constant => c;
  int get degree {
    if (a.abs() >= 1e-9) return 2;
    if (b.abs() >= 1e-9) return 1;
    return 0;
  }

  Poly operator +(Poly other) => Poly(a + other.a, b + other.b, c + other.c);
  Poly operator -(Poly other) => Poly(a - other.a, b - other.b, c - other.c);

  Poly operator *(Poly other) {
    final na = a * other.c + other.a * c + b * other.b;
    final nb = b * other.c + other.b * c;
    final nc = c * other.c;
    return Poly(na, nb, nc);
  }

  Poly operator /(double value) => Poly(a / value, b / value, c / value);
}
