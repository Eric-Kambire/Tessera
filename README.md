# Tessera 🧮

> **Math Solver Craftsman** — A Flutter-based symbolic math solver with step-by-step IDO (Input-Description-Output) solutions.

[![Flutter](https://img.shields.io/badge/Flutter-3.9+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.9+-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-Private-red)]()

---

## 📖 Overview

Tessera is an intelligent math solver application that parses mathematical expressions, applies transformation rules, and displays step-by-step solutions in a clean, dark-themed UI.

### ✨ Key Features

- **Expression Parsing** — Lexer + Parser for mathematical input (`4 + 5 * 3`, etc.)
- **Rule-Based Solving** — Standard arithmetic and algebraic rules
- **Step-by-Step Display** — IDO format showing each transformation
- **LaTeX Output** — Mathematical notation rendering
- **Dark Theme UI** — Modern, professional interface

---

## 🏗️ Architecture

The project follows **MVVM** (Model-View-ViewModel) with a clean DSL core:

```
lib/
├── main.dart              # App entry point & UI
├── logic/
│   ├── ast_models.dart    # Expression AST (Num, BinOp, etc.)
│   ├── lexer.dart         # Tokenizer
│   ├── parser.dart        # Expression parser
│   ├── solver_engine.dart # Rule application engine
│   ├── solution_models.dart # Step & Solution models
│   └── standard_rules.dart  # Transformation rules
├── models/                # Data models
├── services/              # API services
└── viewmodels/            # State management
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.9+
- Dart 3.9+

### Installation

```bash
# Clone the repository
git clone <repository-url>
cd Tessera

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Usage

1. Enter a mathematical expression (e.g., `4 + 5 * 3`)
2. Tap **RÉSOUDRE** (Solve)
3. View each step with transformations
4. Final result displayed in a highlighted box

---

## 📦 Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `provider` | ^6.1.5 | State management |
| `equatable` | ^2.0.8 | Value equality |
| `http` | ^1.6.0 | API calls |

---

## 🧪 Testing

```bash
flutter test
```

---

## 📝 Roadmap

- [ ] Equation solving (`ax + b = 0`)
- [ ] Quadratic formula support
- [ ] Symbolic simplification
- [ ] Graph visualization
- [ ] Export to LaTeX/PDF

---

## 📄 License

Private — All rights reserved.

---

<p align="center">
  Built with ❤️ using <a href="https://flutter.dev">Flutter</a>
</p>
