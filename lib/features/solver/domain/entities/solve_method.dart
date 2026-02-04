enum SolveMethod {
  auto,
  factoring,
  quadraticFormula,
  completingSquare,
}

String solveMethodLabel(SolveMethod method) {
  switch (method) {
    case SolveMethod.auto:
      return 'Automatique';
    case SolveMethod.factoring:
      return 'Factorisation';
    case SolveMethod.quadraticFormula:
      return 'Formule quadratique';
    case SolveMethod.completingSquare:
      return 'Complétion du carré';
  }
}
