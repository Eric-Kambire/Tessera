<p align="center">
  <h1 align="center">🧮 Tessera</h1>
  <p align="center">
    <strong>Offline Mathematical Problem Solver with Step-by-Step Solutions</strong>
  </p>
  <p align="center">
    <a href="#features">Features</a> •
    <a href="#architecture">Architecture</a> •
    <a href="#getting-started">Getting Started</a> •
    <a href="#tech-stack">Tech Stack</a>
  </p>
</p>

---

## 📖 Overview

**Tessera** is a native mobile application (iOS/Android) built with Flutter that solves mathematical problems **100% offline**. It provides a premium educational experience by breaking down solutions into pedagogical step-by-step explanations using the IDO (Input-Description-Output) format.

> 🎯 **Mission:** Empower students with an intuitive, beautiful, and completely offline math learning tool.

---

## ✨ Features

### 📷 Smart OCR Scanner
- Camera-based equation recognition
- Adjustable crop area for precise scanning
- Auto-preprocessing (grayscale, binarization)
- Hybrid OCR: ML Kit + Custom TFLite model for complex symbols

### 🧮 Intelligent Step-by-Step Solver
- Powered by **mathsteps** JavaScript engine (used by Google's Socratic)
- Each step follows the **IDO format**:
  - **Input:** State before transformation
  - **Description:** Clear explanation of the action
  - **Output:** Result with highlighted changes

### ⌨️ Custom Math Keyboard
- iOS/Photomath-inspired design
- Organized tabs: Numbers, Functions, Operators, Letters
- Real-time WYSIWYG LaTeX preview
- Template support and long-press variants

### 📐 Beautiful LaTeX Rendering
- Native mathematical expression rendering
- Offline MathJax integration via flutter_tex
- Syntax highlighting for changed terms

### 💾 Offline-First Architecture
- Zero cloud dependencies for core functionality
- Local history storage with Hive
- Instant results with no network latency

---

## 🏗 Architecture

Tessera follows a **Feature-First Clean Architecture** pattern with **BLoC** for state management.

```
lib/
├── app/                        # Global configuration
│   ├── themes/                 # Light/Dark themes
│   ├── routes/                 # go_router navigation
│   └── locales/                # Internationalization
│
├── core/                       # Shared utilities
│   ├── constants/              # Colors, timeouts
│   ├── usecases/               # UseCase interface
│   └── utils/                  # LaTeX parser, Image utils
│
├── features/                   # Feature modules
│   ├── scanner/                # OCR & Camera
│   │   ├── data/               # Camera, TFLite sources
│   │   ├── domain/             # MathProblem entity
│   │   └── presentation/       # CameraScreen, Overlay
│   │
│   ├── solver/                 # Math engine
│   │   ├── data/               # JS engine wrapper
│   │   ├── domain/             # SolutionStep entity
│   │   └── presentation/       # SolutionPage
│   │
│   └── keyboard/               # Math keyboard
│       └── presentation/       # MathKeyboard widget
│
├── logic/                      # Business logic
├── models/                     # Data models
├── services/                   # App services
├── viewmodels/                 # ViewModel layer
│
├── main.dart                   # Entry point
└── injector.dart               # Dependency injection
```

---

## 🎨 Design System

### Color Palette

| Color | Hex | Usage |
|-------|-----|-------|
| 🔵 Primary Blue | `#0DA2CC` | Variables, active elements |
| 🟢 Secondary Green | `#6EB819` | Results, validations |
| 🟠 Tertiary Orange | `#FD602E` | Operations, focus, cursors |
| ⚫ Neutral Gray | `#7F7F7F` | Explanatory text |

### IDO Step Display

```
┌──────────────────────────────────────┐
│  2x + 4 = 10                         │  INPUT (LaTeX)
├──────────────────────────────────────┤
│  Subtract 4 from both sides          │  DESCRIPTION
├──────────────────────────────────────┤
│  2x = 6                              │  OUTPUT (changes in orange)
└──────────────────────────────────────┘
```

---

## 🛠 Tech Stack

| Layer | Technology |
|-------|------------|
| **Framework** | Flutter (Latest Stable) |
| **Language** | Dart |
| **State Management** | flutter_bloc |
| **Dependency Injection** | get_it + injectable |
| **Navigation** | go_router |
| **Local Storage** | Hive |
| **OCR** | google_mlkit_text_recognition + TFLite |
| **Math Engine** | mathsteps (JS) via flutter_js |
| **Math Rendering** | flutter_tex |
| **Immutability** | freezed |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.x or later)
- Dart SDK
- Android Studio / Xcode (for respective platform builds)

### Installation

```bash
# Clone the repository
git clone https://github.com/Eric-Kambire/Tessera.git

# Navigate to project
cd Tessera

# Install dependencies
flutter pub get

# Generate code (freezed, injectable, etc.)
dart run build_runner build --delete-conflicting-outputs
```

### Running the App

```bash
# Run in debug mode
flutter run

# Run on specific device
flutter run -d <device_id>

# Build for release
flutter build apk          # Android
flutter build ios          # iOS
```

### Running Tests

```bash
# All tests
flutter test

# With coverage
flutter test --coverage

# Specific test
flutter test test/features/solver/domain/solve_equation_test.dart
```

---

## 📁 Important Files

| File | Purpose |
|------|---------|
| `lib/main.dart` | Application entry point |
| `lib/injector.dart` | Dependency injection setup |
| `assets/js/math-engine.bundle.js` | Bundled mathsteps engine |
| `GEMINI.md` | AI development guidelines |
| `AGENT.md` | AI agent instructions |

---

## 🗺 Roadmap

- [x] Core architecture setup
- [x] Custom math keyboard
- [x] Step-by-step solver UI
- [ ] OCR scanner integration
- [ ] History & favorites
- [ ] Multiple equation types (quadratic, trigonometric)
- [ ] Graphing capabilities
- [ ] Multi-language support

---

## 📝 Development Notes

- The math engine bundle is located at `assets/js/math-engine.bundle.js`
- All mathematical processing happens offline in a JS runtime
- Use `freezed` for all immutable data classes
- Follow the IDO format strictly for solution steps

---

## 📄 License

**Private** - All rights reserved.

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/Eric-Kambire">Eric Kambire</a>
</p>
