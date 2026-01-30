# Tessera

A Flutter-based math solver with step-by-step solutions, LaTeX rendering, and a custom math keyboard.

## Overview
Tessera turns typed math into structured steps and a final answer. The UI includes a dedicated math canvas and an iOS/Photomath-inspired keyboard for fast entry.

## Key Features
- Step-by-step solver output
- LaTeX rendering for readable math
- Custom math keyboard with templates and long-press variants
- Offline JS math engine bundle integration

## Project Structure (High Level)
```
lib/
  app/
  core/
  features/
    keyboard/
    solver/
assets/
  js/
    math-engine.bundle.js
```

## Getting Started
### Prerequisites
- Flutter SDK
- Dart SDK

### Install
```bash
git clone <repo-url>
cd Tessera
flutter pub get
```

### Run
```bash
flutter run
```

## Notes
- The math engine bundle lives at `assets/js/math-engine.bundle.js`.
- Keep large build artifacts out of version control.

## License
Private. All rights reserved.
