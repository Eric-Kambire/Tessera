## ✅ Problems It Can Solve

**Currently supported (engine-backed):**
- Linear equations in one variable (e.g., `2x + 4 = 10`)
- Equations with fractions, powers, roots, and constants (when supported by the engine)
- Basic arithmetic expressions that appear inside equations

**Added support (quadratic equations):**
- Standard quadratic form `ax^2 + bx + c = 0`
- Examples: `x^2 - 5x + 6 = 0`, `2x^2 + 3x - 2 = 0`
- Uses discriminant and quadratic formula

**Added support (identités remarquables):**
- `(a+b)^2` → `a^2 + 2ab + b^2`
- `(a-b)^2` → `a^2 - 2ab + b^2`
- `(a+b)(a-b)` → `a^2 - b^2`

**Added support (fractions):**
- Simplification: `4/8` → `1/2`
- Addition/Subtraction: `1/2 + 1/3` → `5/6`
- Multiplication: `2/3 * 3/4` → `1/2`
- Division: `3/5 ÷ 2/7` → `21/10`
- With x (same power): `x/2 + x/3` → `5x/6`

**Input normalization supported:**
- Unicode operators (× ÷ −) → `* / -`
- `π` → `pi`
- `√` / `∛` → `sqrt / cbrt`
- `frac(a,b)` → `(a)/(b)`
- Percentage values like `25%` → `(25/100)`

**Not yet supported (planned):**
- Systems of equations
- Graphing
- Advanced calculus proofs
- Full symbolic simplification without an equation
