import '../models/keyboard_mode.dart';
import '../models/key_action.dart';
import 'math_symbols.dart';

/// Defines the exact 6-column grid layout for each keyboard mode
abstract class KeyboardLayouts {
  
  static List<List<KeyDefinition>> getLayout(KeyboardMode mode) {
    switch (mode) {
      case KeyboardMode.basicArithmetic:
        return _basicArithmetic;
      case KeyboardMode.functionsLog:
        return _functionsLog;
      case KeyboardMode.trigonometry:
        return _trigonometry;
      case KeyboardMode.limitsDiffInt:
        return _limitsDiffInt;
      case KeyboardMode.alphabet:
        return _alphabet;
    }
  }

  // 6 COLUMNS: [Func1] [Func2] [7] [8] [9] [/]
  static const _basicArithmetic = [
    [
      KeyDefinition(label: '( )', action: InsertTemplate('()', cursorOffset: 1)),
      KeyDefinition(label: '>', popupItems: ['>', '≥', '<', '≤'], action: InsertSymbol('>')),
      KeyDefinition(label: '7', action: InsertSymbol('7'), isNumber: true),
      KeyDefinition(label: '8', action: InsertSymbol('8'), isNumber: true),
      KeyDefinition(label: '9', action: InsertSymbol('9'), isNumber: true),
      KeyDefinition(label: MathSymbols.division, action: InsertSymbol('/')),
    ],
    [
      KeyDefinition(label: '√□', popupItems: ['√', '∛', 'ⁿ√'], action: InsertTemplate('sqrt()', cursorOffset: 1)),
      KeyDefinition(label: '|□|', action: InsertTemplate('abs()', cursorOffset: 1)),
      KeyDefinition(label: '4', action: InsertSymbol('4'), isNumber: true),
      KeyDefinition(label: '5', action: InsertSymbol('5'), isNumber: true),
      KeyDefinition(label: '6', action: InsertSymbol('6'), isNumber: true),
      KeyDefinition(label: MathSymbols.multiplication, action: InsertSymbol('*')),
    ],
    [
      KeyDefinition(label: '□²', popupItems: ['□²', '□³', '□ⁿ'], action: InsertTemplate('^2', cursorOffset: 0)),
      KeyDefinition(label: 'x', popupItems: ['x', 'y', 'z'], action: InsertSymbol('x')),
      KeyDefinition(label: '1', action: InsertSymbol('1'), isNumber: true),
      KeyDefinition(label: '2', action: InsertSymbol('2'), isNumber: true),
      KeyDefinition(label: '3', action: InsertSymbol('3'), isNumber: true),
      KeyDefinition(label: MathSymbols.minus, action: InsertSymbol('-')),
    ],
    [
      KeyDefinition(label: 'π', popupItems: ['π', 'e', 'φ'], action: InsertSymbol(MathSymbols.pi)),
      KeyDefinition(label: '%', action: InsertSymbol('%')),
      KeyDefinition(label: '0', action: InsertSymbol('0'), isNumber: true),
      KeyDefinition(label: '.', action: InsertSymbol('.')),
      KeyDefinition(label: '=', action: EvaluateExpression(), isHighlighted: true),
      KeyDefinition(label: MathSymbols.plus, action: InsertSymbol('+')),
    ],
  ];

  static const _functionsLog = [
    [
      KeyDefinition(label: 'f(x)', action: InsertSymbol('f(x)')),
      KeyDefinition(label: 'g(x)', action: InsertSymbol('g(x)')),
      KeyDefinition(label: 'log', action: InsertTemplate('log()', cursorOffset: 1)),
      KeyDefinition(label: 'ln', action: InsertTemplate('ln()', cursorOffset: 1)),
      KeyDefinition(label: 'e', action: InsertSymbol('e')),
      KeyDefinition(label: '!', action: InsertSymbol('!')),
    ],
    // Fillers for 6-col Structure
    [
      KeyDefinition(label: 'sin', action: InsertTemplate('sin()', cursorOffset: 1)),
      KeyDefinition(label: 'cos', action: InsertTemplate('cos()', cursorOffset: 1)),
      KeyDefinition(label: 'tan', action: InsertTemplate('tan()', cursorOffset: 1)),
      KeyDefinition(label: 'cot', action: InsertTemplate('cot()', cursorOffset: 1)),
      KeyDefinition(label: 'sinh', action: InsertTemplate('sinh()', cursorOffset: 1)),
      KeyDefinition(label: 'cosh', action: InsertTemplate('cosh()', cursorOffset: 1)),
    ],
    [
      KeyDefinition(label: 'lim', action: InsertSymbol('lim')),
      KeyDefinition(label: 'sum', action: InsertSymbol('sum')),
      KeyDefinition(label: 'prod', action: InsertSymbol('prod')),
      KeyDefinition(label: 'int', action: InsertSymbol('int')),
      KeyDefinition(label: 'dy/dx', action: InsertSymbol('d/dx')),
      KeyDefinition(label: 'dt', action: InsertSymbol('dt')),
    ],
    [
      KeyDefinition(label: 'Matrix', action: OpenModal('matrix')),
      KeyDefinition(label: 'Det', action: OpenModal('determinant')),
      KeyDefinition(label: 'i', action: InsertSymbol('i')),
      KeyDefinition(label: ',', action: InsertSymbol(',')),
      KeyDefinition(label: '(', action: InsertSymbol('(')),
      KeyDefinition(label: ')', action: InsertSymbol(')')),
    ],
  ];

  static const _trigonometry = _functionsLog; // Placeholder
  static const _limitsDiffInt = _functionsLog; // Placeholder
  static const _alphabet = _functionsLog; // Placeholder
}

class KeyDefinition {
  final String label;
  final KeyAction action;
  final List<String>? popupItems;
  final bool isHighlighted; 
  final bool isNumber; // For styling distinction

  const KeyDefinition({
    required this.label,
    required this.action,
    this.popupItems,
    this.isHighlighted = false,
    this.isNumber = false,
  });

  bool get hasVariants => popupItems != null && popupItems!.isNotEmpty;
}
