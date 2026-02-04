## ? Problems It Can Solve

**Currently supported (engine-backed):**
- Linear equations in one variable (e.g., `2x + 4 = 10`)
- Equations with fractions, powers, roots, and constants (when supported by the engine)
- Basic arithmetic expressions that appear inside equations

**Added support (CAS offline):**
- Linear equations (including coefficients with radicals), with optional rationalization.
- Quadratic equations with selectable method: factoring, quadratic formula, or completing the square.
- Polynomial equations up to degree 4 when they can be expanded to a polynomial form.
- Radical equations:
  - Single radical isolation and squaring.
  - Double-radical isolation and double squaring.
  - Mixed forms like `x^2 + x?x = 0` and `x?x + ax = 0`.
- Trigonometric equations of the form `sin(x)=a`, `cos(x)=a`, `tan(x)=a`, and `sin(x)=cos(x)`.
- Log/ln equations with constant right-hand side (e.g., `ln(x)=2`).
- Inequalities for linear and quadratic polynomials (solution as intervals).
- Step-by-step explanations with academic style and expanded layout.

**Added support (identit?s remarquables):**
- `(a+b)^2` ? `a^2 + 2ab + b^2`
- `(a-b)^2` ? `a^2 - 2ab + b^2`
- `(a+b)(a-b)` ? `a^2 - b^2`

**Added support (fractions):**
- Simplification: `4/8` ? `1/2`
- Addition/Subtraction: `1/2 + 1/3` ? `5/6`
- Multiplication: `2/3 * 3/4` ? `1/2`
- Division: `3/5 ? 2/7` ? `21/10`
- With x (same power): `x/2 + x/3` ? `5x/6`

**Input normalization supported:**
- Unicode operators (? ? ?) ? `* / -`
- `?` ? `pi`
- `?` / `?` ? `sqrt / cbrt`
- `frac(a,b)` ? `(a)/(b)`
- Percentage values like `25%` ? `(25/100)`

**Not yet supported (planned):**
- Systems of equations
- Graphing
- Advanced calculus proofs
- Full symbolic simplification without an equation
