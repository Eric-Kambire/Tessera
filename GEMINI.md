# **Tessera - AI Development Guidelines**

These guidelines define the operational principles and capabilities for AI agents working on the Tessera project - an offline mathematical problem-solving Flutter application.

---

## **Project Overview**

**Tessera** is a mobile application (iOS/Android) built with Flutter that solves mathematical problems **100% offline**. It features:
- OCR-based math recognition (camera scanning)
- Step-by-step solution breakdown (IDO format: Input-Description-Output)
- Custom mathematical keyboard
- LaTeX rendering for mathematical expressions
- Offline JavaScript math engine (mathsteps)

---

## **Core Principles**

### **🎯 Project Objectives**

1. **100% Offline Operation** - No cloud API dependencies for solving or OCR
2. **Clean Architecture** - Feature-First Clean Architecture with BLoC pattern
3. **IDO Standards** - Strict Input-Description-Output format for solution steps
4. **Premium UX** - Polished design, smooth animations, native LaTeX rendering

---

## **Technical Stack**

| Component | Technology |
|-----------|------------|
| **Framework** | Flutter (Latest Stable) |
| **Language** | Dart |
| **State Management** | flutter_bloc |
| **Dependency Injection** | get_it + injectable |
| **Navigation** | go_router |
| **Local Database** | Hive (NoSQL for history) |
| **OCR Engine** | google_mlkit_text_recognition + TFLite Custom |
| **Math Engine** | mathsteps (JS) via flutter_js (QuickJS) |
| **Math Rendering** | flutter_tex (Offline MathJax) |

---

## **Project Architecture**

### **Directory Structure (lib/)**

```
lib/
├── app/                        # Global config (Themes, Routes, Locales)
├── core/                       # Shared code (Utils, Constants, Errors)
│   ├── constants/              # Color codes, timeouts
│   ├── usecases/               # Generic UseCase interface
│   └── utils/                  # LatexParser, ImageUtils
├── features/                   # Functional modules (Feature-First)
│   ├── scanner/                # Camera & OCR feature
│   │   ├── data/               # Data sources (Camera, TFLite)
│   │   ├── domain/             # Entities (MathProblem), UseCases
│   │   └── presentation/       # BLoC, Pages, Widgets
│   ├── solver/                 # Resolution engine feature
│   │   ├── data/               # MathEngineService (flutter_js wrapper)
│   │   ├── domain/             # Entities (SolutionStep, Explanation)
│   │   └── presentation/       # SolutionPage, StepsWidget
│   └── keyboard/               # Custom Math Keyboard feature
├── logic/                      # Business logic components
├── models/                     # Data models
├── services/                   # Application services
├── viewmodels/                 # ViewModel layer
├── main.dart                   # Entry point
└── injector.dart               # Dependency Injection setup
```

---

## **Design System**

### **Color Palette (Strict Compliance)**

| Color | Hex Code | Usage |
|-------|----------|-------|
| **Primary (Blue)** | `#0DA2CC` | Variables, active elements |
| **Secondary (Green)** | `#6EB819` | Results, validations |
| **Tertiary (Orange)** | `#FD602E` | Operations, focus, cursors |
| **Neutral (Gray)** | `#7F7F7F` | Explanatory text |
| **Background** | White / Deep Dark Mode | No dirty grays |

### **IDO Step Format**

Each solving step MUST be displayed as a widget with 3 vertical blocks:

1. **Input (LaTeX Block)** - Equation state **before** transformation
   - Rule: Must match the Output of the previous step
   
2. **Description (Text)** - Complete sentence explaining the action
   - Style: Sans-serif font, color `#7F7F7F`
   - No "I" or "We" pronouns
   
3. **Output (LaTeX Block)** - Result **after** transformation
   - Changed terms highlighted in Orange (`#FD602E`)

---

## **Math Engine Specifications**

### **Hybrid Engine: flutter_js + mathsteps**

The engine uses JavaScript's `mathsteps` library (used by Socratic/Google) for pedagogical step decomposition.

#### **Implementation**
1. Bundle JS file at `assets/js/math-engine.bundle.js`
2. Initialize `JavascriptRuntime` at startup (in an Isolate)
3. Expose `solve(String latexInput)` function returning structured JSON

#### **Output JSON Structure**

```json
{
  "problem_latex": "2x + 4 = 10",
  "steps": [
    {
      "step_id": 1,
      "type": "IDO",
      "input_latex": "2x + 4 = 10",
      "description_key": "subtract_from_both_sides",
      "output_latex": "2x = 6",
      "changed_indices": [2, 3]
    },
    {
      "step_id": 2,
      "type": "IDO",
      "input_latex": "2x = 6",
      "description_key": "divide_both_sides",
      "output_latex": "x = 3"
    }
  ],
  "final_answer": "x = 3"
}
```

---

## **Scanner Module (OCR)**

### **Camera Interface (UX)**
- **Widget:** Full-screen CameraPreview
- **Overlay:** Adjustable crop box with rounded corners (`#0DA2CC`)
- **Feedback:** Loading indicator on frame during analysis

### **Recognition Pipeline**
1. **Capture:** Image captured and cropped
2. **Preprocessing:** Grayscale conversion + binarization
3. **OCR:**
   - Level 1: ML Kit for simple linear equations
   - Level 2: Custom TFLite model (IM2LATEX dataset) for complex symbols
4. **Conversion:** Raw result → standardized LaTeX string

---

## **Custom Math Keyboard**

- **Custom Widget:** `MathKeyboard` animating from bottom
- **Layout:** Tabs for [Numbers], [Functions f(x)], [Operators], [Letters]
- **Real-time Rendering:** WYSIWYG LaTeX display using flutter_tex

---

## **Code Standards**

### **Documentation**
- Use `///` for public function documentation
- Comment complex algorithms (especially JS ↔ Dart mapping)
- English or clear French technical language

### **Immutability**
- Use `freezed` for all data classes (Entities/States)
- Ensures immutability and prevents state bugs

### **Testing**
- **Unit Tests:** Mandatory for all `domain/` code (mathematical logic)
- **Widget Tests:** Verify LaTeX rendering displays without errors

### **Error Handling**
- Centralized error handling with proper try-catch blocks
- Graceful degradation when OCR fails
- Clear user feedback for unrecognized equations

---

## **Development Workflow**

### **Post-Modification Checks**
After every code change:
1. Monitor IDE diagnostics and terminal output
2. Check preview server for rendering issues
3. Run `flutter analyze` for warnings
4. Execute relevant tests with `flutter test`

### **Automatic Error Correction**
The AI will attempt to fix:
- Syntax errors
- Type mismatches and null-safety violations
- Unresolved imports
- Linting violations (`flutter fix --apply .`)
- Common Flutter issues (setState on unmounted widget, etc.)

---

## **Firebase MCP Configuration**

When Firebase integration is requested, add to `.idx/mcp.json`:

```json
{
    "mcpServers": {
        "firebase": {
            "command": "npx",
            "args": [
                "-y",
                "firebase-tools@latest",
                "experimental:mcp"
            ]
        }
    }
}
```

---

## **Quick Commands**

```bash
# Run the app
flutter run

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
dart format .

# Add dependency
flutter pub add <package_name>

# Code generation
dart run build_runner build --delete-conflicting-outputs
```