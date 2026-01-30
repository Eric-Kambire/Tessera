# **Tessera - Agent Instructions**

This document provides specific instructions for AI agents working on the Tessera project.

---

## **Quick Context**

**Tessera** is an offline Flutter math solver app with:
- 📷 OCR-based equation scanning
- 🧮 Step-by-step solutions (IDO format)
- ⌨️ Custom math keyboard
- 📐 LaTeX rendering
- 🔌 Offline JS math engine

---

## **Before Any Change**

1. **Read `GEMINI.md`** - Contains project-specific guidelines
2. **Check `blueprint.md`** - Current project state and features (if exists)
3. **Understand the architecture** - Feature-First Clean Architecture

---

## **Key Files & Locations**

| Purpose | Location |
|---------|----------|
| Entry Point | `lib/main.dart` |
| Dependency Injection | `lib/injector.dart` |
| Math Engine Bundle | `assets/js/math-engine.bundle.js` |
| Keyboard Feature | `lib/features/keyboard/` |
| Solver Feature | `lib/features/solver/` |
| Scanner Feature | `lib/features/scanner/` |

---

## **Critical Rules**

### **1. Maintain Offline Capability**
- ❌ Never add cloud API dependencies for core solving
- ❌ Never require internet for math processing
- ✅ All computation must happen locally

### **2. Follow IDO Format**
Every solution step must have:
```
┌─────────────────────────────┐
│ INPUT (LaTeX before)        │  ← Same as previous OUTPUT
├─────────────────────────────┤
│ DESCRIPTION (Explanation)   │  ← No "I" or "We" pronouns
├─────────────────────────────┤
│ OUTPUT (LaTeX after)        │  ← Changed parts in #FD602E
└─────────────────────────────┘
```

### **3. Use Project Colors**
```dart
// Use these exact colors
const Color primaryBlue = Color(0xFF0DA2CC);    // Variables, active
const Color secondaryGreen = Color(0xFF6EB819); // Results, valid
const Color tertiaryOrange = Color(0xFFFD602E); // Operations, focus
const Color neutralGray = Color(0xFF7F7F7F);    // Explanations
```

### **4. State Management**
- Use `flutter_bloc` for feature-level state
- Use `provider` for app-wide state (theme, etc.)
- Use `ValueNotifier` for simple local state

---

## **Adding New Features**

### **Step-by-Step Process**

1. **Create feature folder** in `lib/features/<feature_name>/`
2. **Follow structure:**
   ```
   <feature_name>/
   ├── data/           # Repositories, data sources
   ├── domain/         # Entities, use cases
   └── presentation/   # BLoC, pages, widgets
   ```
3. **Register in DI** - Update `lib/injector.dart`
4. **Add tests** - Minimum unit tests for domain layer
5. **Update blueprint** - Document in `blueprint.md`

---

## **Working with Math Engine**

### **Adding New Math Operations**

1. **Update JS bundle** - Modify source and rebuild `math-engine.bundle.js`
2. **Update Dart wrapper** - Handle new operation in `MathEngineService`
3. **Add description keys** - Update i18n for step explanations
4. **Test thoroughly** - Add unit tests for new operations

### **JS ↔ Dart Communication**

```dart
// Example: Calling the math engine
final result = await _jsRuntime.evaluate('''
  solve("${latexInput.toJsString()}");
''');
final jsonResult = jsonDecode(result.stringResult);
```

---

## **Testing Requirements**

### **Mandatory Tests**

| Layer | Test Type | Coverage |
|-------|-----------|----------|
| `domain/` | Unit Tests | All use cases, entities |
| `presentation/` | Widget Tests | LaTeX rendering, keyboard |
| Integration | E2E Tests | Full solve flow |

### **Running Tests**

```bash
# All tests
flutter test

# Specific test file
flutter test test/features/solver/domain/solve_equation_test.dart

# With coverage
flutter test --coverage
```

---

## **Common Tasks**

### **Add New Package**
```bash
flutter pub add <package_name>
flutter pub add dev:<dev_package_name>  # for dev dependencies
```

### **Code Generation**
```bash
dart run build_runner build --delete-conflicting-outputs
```

### **Fix Lint Issues**
```bash
flutter fix --apply .
dart format .
```

---

## **Troubleshooting**

### **JS Engine Not Loading**
- Verify `assets/js/math-engine.bundle.js` exists
- Check `pubspec.yaml` assets declaration
- Ensure Isolate is properly initialized

### **LaTeX Not Rendering**
- Verify `flutter_tex` is configured for offline
- Check local MathJax files are present
- Test with simple equation first

### **OCR Returning Empty**
- Check camera permissions
- Verify ML Kit is initialized
- Test preprocessing pipeline with sample images

---

## **Git Workflow**

```bash
# Before pushing
flutter analyze
flutter test

# Commit with descriptive message
git add -A
git commit -m "feat(solver): add quadratic equation support"
git push origin main
```

---

## **Performance Considerations**

1. **Isolates** - Run JS engine in separate isolate
2. **Lazy Loading** - Don't initialize all features at startup
3. **Image Processing** - Compress images before OCR
4. **Widget Rebuilds** - Use `const` constructors where possible

---

## **Contact & Resources**

- **Repository:** [github.com/Eric-Kambire/Tessera](https://github.com/Eric-Kambire/Tessera)
- **Development Plan:** `Plan de Développement _ Math Solver Flutter Offline.md`
- **AI Guidelines:** `GEMINI.md`
