# CAS Architecture (Offline)

This document explains the internal CAS (computer algebra system) used by Tessera to solve equations offline with step-by-step IDO output. The CAS is intentionally small, predictable, and focused on Tle-level algebra.

**Scope**
The CAS currently supports:
- Single-variable equations in `x`
- Operators: `+`, `-`, `*`, `/`, `^`
- Parentheses
- `sqrt(...)`
- Trig nodes: `sin(...)`, `cos(...)`, `tan(...)`
- Log nodes: `log(...)`, `ln(...)`
- Constants: `pi`, `e`
- Polynomial solving up to degree 2
- Radical equations with **one or two** square roots
- Logarithmic equations with constant right-hand side
- Trigonometric equations with constant right-hand side
- Inequalities (linear and quadratic)
- Linear equations with radical coefficients (rationalization supported)
- Mixed quadratic–radical equations of the form `x^2 + x\sqrt{x} = 0`
- Mixed radical–linear equations of the form `x\sqrt{x} + ax = 0`
- Rationalization of denominators with one or two radicals

It intentionally does **not** handle:
- Full symbolic simplification beyond degree 4
- Multi-variable systems
- High-degree polynomials

---

## 1. Core Components

**AST (Expression Tree)**
File: `lib/core/cas/expr.dart`
- Nodes: `Num`, `Var`, `Const`, `Neg`, `Add`, `Sub`, `Mul`, `Div`, `Pow`, `Func`
- `Func(name, arg)` represents `sqrt/sin/cos/tan/log/ln` and any future functions.

**Statement AST**
File: `lib/core/cas/statement.dart`
- `Equation(left, right)`
- `Inequality(left, right, op)`
- Each node can:
  - Render LaTeX with `toLatex()`
  - Count sqrt occurrences with `sqrtCount()`
  - Evaluate numerically with `eval(...)`
  - Convert to polynomial form with `toPoly()` (if possible)

**Polynomial Form**
File: `lib/core/cas/poly.dart`
- Represents `ax^2 + bx + c`
- Supports `+`, `-`, `*`, and division by constant
- Prevents degree > 2 by returning `null` during AST conversion

**Parser**
File: `lib/core/cas/parser.dart`
- Tokenizes input
- Inserts implicit multiplication: `2x` → `2*x`, `x(x+1)` → `x*(x+1)`
- Uses a shunting-yard algorithm to build AST
- Handles unary minus via a `Neg` node
- Builds `Func(name, arg)` for `sqrt/sin/cos/tan/log/ln`
- Parses full statements (equations or inequalities)
- Recognizes constants `pi`, `e`

**Simplifier**
File: `lib/core/cas/simplifier.dart`
- Expands and collects polynomial expressions where possible (up to degree 4)
- Reduces numeric operations and trivial multiplications/divisions

**CAS Solver**
File: `lib/core/cas/solver.dart`
- Solves `ax^2 + bx + c = 0`
- Uses discriminant for quadratics
- Validates solutions against the original equation (important for radicals)

**Equation Solver (Domain)**
File: `lib/features/solver/domain/services/cas_equation_solver.dart`
- Orchestrates parsing, simplification, and solving
- Emits IDO steps (`SolutionStep`)
- Supports polynomial equations and radical equations

---

## 2. Execution Pipeline

For an equation `left = right`:
1. Normalize input with `normalizeForEngine(...)`
2. Parse both sides into AST
3. If radicals are present:
   - If one radical: isolate → square → solve → verify
   - If two radicals: isolate one → square → isolate second → square → solve → verify
4. If no radicals:
   - Convert `left - right` to polynomial
   - Solve directly
5. For trig/log equations:
   - Apply the appropriate inverse function and solve the resulting polynomial
6. For inequalities:
   - Reduce to `f(x) < 0` (or `≤`, `>`, `≥`)
   - Use sign analysis to produce interval solutions

---

## 3. Radical Strategy

The CAS handles equations with **one or two** square roots.
Nested radicals are supported when there is a single top-level `sqrt(...)` on one side.

Special case handled:
- `x^2 + x\sqrt{x} = 0` → rewrite as `x^2 + x^{3/2} = 0`, factor `x^{3/2}`, apply product-null property, and enforce `x \ge 0`.

Example:
```
sqrt(x + 1) = 3
```
Steps:
1. Isolate `sqrt(x + 1)`
2. Square both sides: `x + 1 = 9`
3. Solve polynomial: `x = 8`
4. Check in original equation

For two radicals:
```
sqrt(x + 1) + sqrt(x - 2) = 5
```
Steps:
1. Isolate one radical
2. Square
3. Isolate the second radical
4. Square again
5. Solve polynomial and validate solutions

---

## 4. Trig Strategy

Supported forms:
- `sin(x) = a`
- `cos(x) = a`
- `tan(x) = a`
- `sin(x) = cos(x)`

The solver outputs the standard general solution in terms of `k`.

---

## 5. Log Strategy

Supported forms:
- `ln(f(x)) = k`
- `log(f(x)) = k` (base 10)

Steps:
1. Exponentiate both sides
2. Solve the resulting polynomial
3. Validate solutions (domain check)

---

## 6. Inequality Strategy

Supported forms:
- Linear and quadratic inequalities

Steps:
1. Move everything to one side
2. Compute roots and sign of the polynomial
3. Output interval solution

---

## 7. Linear Equations with Radicals

Supported form:
- `ax + b = 0` where `a` and/or `b` include radicals such as `\sqrt{3}`

Steps:
1. Gather terms on one side
2. Isolate the linear term
3. Divide by the coefficient
4. Rationalize the denominator when it is of the form `a + b\sqrt{c}`
   - If the denominator has two radicals, two conjugations are used.


---

## 4. Step-By-Step Output (IDO)

Each transformation produces a `SolutionStep` with:
- Input LaTeX
- Description in full sentence
- Output LaTeX

Examples of CAS descriptions:
- "Mettre l’équation sous la forme f(x) = 0."
- "Isoler la racine carrée."
- "Élever les deux membres au carré."
- "Vérifier les solutions dans l’équation initiale."

---

## 5. Design Goals

- Fully offline, no external CAS dependencies
- Minimal feature set, but highly reliable
- Predictable step explanations for learning
- Strict domain validation for radical equations

---

## 8. Extending the CAS

Recommended next steps:
- Add trig/log solving strategies (separate from this CAS core)
- Expand algebraic simplification to handle higher-degree polynomials
