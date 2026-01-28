import '../models/keyboard_mode.dart';
import '../models/key_action.dart';
import 'math_symbols.dart';

/// Defines the grid layout for each keyboard mode
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

  // Definition helper
  static const _basicArithmetic = [
    [
      KeyDefinition(label: '( )', action: InsertTemplate('()', cursorOffset: 1)),
      KeyDefinition(label: '>', popupItems: ['>', '≥', '<', '≤'], action: InsertSymbol('>')),
      KeyDefinition(label: '7', action: InsertSymbol('7')),
      KeyDefinition(label: '8', action: InsertSymbol('8')),
      KeyDefinition(label: '9', action: InsertSymbol('9')),
      KeyDefinition(label: MathSymbols.division, action: InsertSymbol('/')),
    ],
    [
      KeyDefinition(label: '√□', popupItems: ['√', '∛', 'ⁿ√'], action: InsertTemplate('sqrt()', cursorOffset: 1)),
      KeyDefinition(label: '|□|', action: InsertTemplate('abs()', cursorOffset: 1)), // Placeholder for 2,1 extra
      KeyDefinition(label: '4', action: InsertSymbol('4')),
      KeyDefinition(label: '5', action: InsertSymbol('5')),
      KeyDefinition(label: '6', action: InsertSymbol('6')),
      KeyDefinition(label: MathSymbols.multiplication, action: InsertSymbol('*')),
    ],
    [
      KeyDefinition(label: '□²', popupItems: ['□²', '□³', '□ⁿ'], action: InsertTemplate('^2', cursorOffset: 0)), // Postfix
      KeyDefinition(label: 'x', popupItems: ['x', 'y', 'z'], action: InsertSymbol('x')),
      KeyDefinition(label: '1', action: InsertSymbol('1')),
      KeyDefinition(label: '2', action: InsertSymbol('2')),
      KeyDefinition(label: '3', action: InsertSymbol('3')),
      KeyDefinition(label: MathSymbols.minus, action: InsertSymbol('-')),
    ],
    [
      KeyDefinition(label: 'π', popupItems: ['π', 'e'], action: InsertSymbol(MathSymbols.pi)),
      KeyDefinition(label: '%', action: InsertSymbol('%')),
      KeyDefinition(label: '0', action: InsertSymbol('0')),
      KeyDefinition(label: '.', action: InsertSymbol('.')),
      KeyDefinition(label: '=', action: EvaluateExpression(), isHighlighted: true),
      KeyDefinition(label: MathSymbols.plus, action: InsertSymbol('+')),
    ],
  ];

  static const _functionsLog = [
    [
      KeyDefinition(label: 'f(x)', action: InsertSymbol('f(x)')),
      KeyDefinition(label: 'log', action: InsertTemplate('log()', cursorOffset: 1)),
      KeyDefinition(label: 'ln', action: InsertTemplate('ln()', cursorOffset: 1)),
      KeyDefinition(label: 'e', action: InsertSymbol('e')),
    ],
    [
      KeyDefinition(label: 'Matrix', action: OpenModal('matrix')), 
      KeyDefinition(label: 'Det', action: OpenModal('determinant')), 
      KeyDefinition(label: '!', action: InsertSymbol('!')), 
      KeyDefinition(label: 'nCr', action: InsertSymbol('nCr')),
    ],
    // Simplified for demo - fill remaining rows with placeholders or common functions
    [
      KeyDefinition(label: 'sin', action: InsertTemplate('sin()', cursorOffset: 1)),
      KeyDefinition(label: 'cos', action: InsertTemplate('cos()', cursorOffset: 1)),
      KeyDefinition(label: 'tan', action: InsertTemplate('tan()', cursorOffset: 1)),
      KeyDefinition(label: 'cot', action: InsertTemplate('cot()', cursorOffset: 1)),
    ], 
    [ 
      KeyDefinition(label: 'lim', action: InsertSymbol('lim')), 
      KeyDefinition(label: 'sum', action: InsertSymbol('sum')), 
      KeyDefinition(label: 'prod', action: InsertSymbol('prod')), 
      KeyDefinition(label: 'int', action: InsertSymbol('int')), 
    ]
  ];

  // Placeholder for other modes to keep file concise for now
  static const _trigonometry = _functionsLog; 
  static const _limitsDiffInt = _functionsLog;
  static const _alphabet = _functionsLog; 
}

class KeyDefinition {
  final String label;
  final String? iconAsset; // If image based
  final KeyAction action;
  final List<String>? popupItems;
  final bool isHighlighted; // For primary action like =

  const KeyDefinition({
    required this.label,
    this.iconAsset,
    required this.action,
    this.popupItems,
    this.isHighlighted = false,
  });
}
