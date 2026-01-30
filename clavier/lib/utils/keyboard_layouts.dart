import '../models/keyboard_mode.dart';
import '../models/key_action.dart';
import 'math_symbols.dart';

/// Defines the exact grid layout for each keyboard mode
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

  /// Returns the number of columns for a given mode
  static int getColumnCount(KeyboardMode mode) {
    switch (mode) {
      case KeyboardMode.trigonometry:
        return 7;
      case KeyboardMode.limitsDiffInt:
        return 5;
      case KeyboardMode.alphabet:
        return 8;
      default:
        return 6;
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
      KeyDefinition(label: '□/□', popupItems: ['□/□', '□(□/□)'], action: InsertTemplate('/', cursorOffset: 1)), // Fraction with variants
      KeyDefinition(label: '√□', popupItems: ['√', '∛', 'ⁿ√'], action: InsertTemplate('sqrt()', cursorOffset: 1)),
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
      KeyDefinition(label: 'π', popupItems: ['π', 'π/2', 'π/3'], action: InsertSymbol(MathSymbols.pi)),
      KeyDefinition(label: '%', action: InsertSymbol('%')),
      KeyDefinition(label: '0', action: InsertSymbol('0'), isNumber: true),
      KeyDefinition(label: ',', action: InsertSymbol(',')),
      KeyDefinition(label: '=', action: EvaluateExpression(), isHighlighted: true),
      KeyDefinition(label: MathSymbols.plus, action: InsertSymbol('+')),
    ],
  ];

  static const _functionsLog = [
    [
      KeyDefinition(label: '|□|', action: InsertTemplate('abs()', cursorOffset: 1)),
      KeyDefinition(label: 'f(x)', action: InsertSymbol('f(x)')),
      KeyDefinition(label: 'log₁₀', action: InsertTemplate('log10()', cursorOffset: 1)),
      KeyDefinition(label: 'nVk', action: InsertCode('permut()')),
      KeyDefinition(label: 'i', action: InsertSymbol('i')),
      KeyDefinition(label: 'list', action: InsertSymbol(',')),
    ],
    [
      KeyDefinition(label: 'Sub', action: InsertSymbol('_')),
      KeyDefinition(label: '□(□)', action: InsertTemplate('f()', cursorOffset: 1)),
      KeyDefinition(label: 'log₂', action: InsertTemplate('log2()', cursorOffset: 1)),
      KeyDefinition(label: 'nPk', action: InsertCode('nPr()')),
      KeyDefinition(label: 'z', action: InsertSymbol('z')),
      KeyDefinition(label: '!', action: InsertSymbol('!')),
    ],
    [
      KeyDefinition(label: 'e', action: InsertSymbol('e')),
      KeyDefinition(label: '□(□,□)', action: InsertTemplate('f(,)', cursorOffset: 2)),
      KeyDefinition(label: 'logₙ', action: InsertTemplate('log()')),
      KeyDefinition(label: 'nCk', action: InsertCode('nCr()')),
      KeyDefinition(label: 'z̄', action: InsertCode('conjugate()')),
      KeyDefinition(label: 'Matrix', action: OpenModal('matrix')),
    ],
    [
      KeyDefinition(label: 'exp', action: InsertTemplate('exp()', cursorOffset: 1)),
      KeyDefinition(label: 'LCM', action: InsertCode('lcm()')),
      KeyDefinition(label: 'ln', action: InsertTemplate('ln()', cursorOffset: 1)),
      KeyDefinition(label: 'Binom', action: InsertCode('nCr()')),
      KeyDefinition(label: 'sign', action: InsertTemplate('sign()', cursorOffset: 1)),
      KeyDefinition(label: '|Mat|', action: OpenModal('determinant')),
    ],
  ];

  // Trigonometry: 4 rows × 7 columns
  static const _trigonometry = [
    [
      KeyDefinition(label: 'rad', action: InsertSymbol('rad')),
      KeyDefinition(label: 'sin', action: InsertTemplate('sin()', cursorOffset: 1)),
      KeyDefinition(label: 'cos', action: InsertTemplate('cos()', cursorOffset: 1)),
      KeyDefinition(label: 'tan', action: InsertTemplate('tan()', cursorOffset: 1)),
      KeyDefinition(label: 'cot', action: InsertTemplate('cot()', cursorOffset: 1)),
      KeyDefinition(label: 'sec', action: InsertTemplate('sec()', cursorOffset: 1)),
      KeyDefinition(label: 'csc', action: InsertTemplate('csc()', cursorOffset: 1)),
    ],
    [
      KeyDefinition(label: '□°', action: InsertSymbol('°')),
      KeyDefinition(label: 'arcsin', action: InsertTemplate('arcsin()', cursorOffset: 1)),
      KeyDefinition(label: 'arccos', action: InsertTemplate('arccos()', cursorOffset: 1)),
      KeyDefinition(label: 'arctan', action: InsertTemplate('arctan()', cursorOffset: 1)),
      KeyDefinition(label: 'arccot', action: InsertTemplate('arccot()', cursorOffset: 1)),
      KeyDefinition(label: 'arcsec', action: InsertTemplate('arcsec()', cursorOffset: 1)),
      KeyDefinition(label: 'arccsc', action: InsertTemplate('arccsc()', cursorOffset: 1)),
    ],
    [
      KeyDefinition(label: "□°□'", action: InsertTemplate("°'", cursorOffset: 1)),
      KeyDefinition(label: 'sinh', action: InsertTemplate('sinh()', cursorOffset: 1)),
      KeyDefinition(label: 'cosh', action: InsertTemplate('cosh()', cursorOffset: 1)),
      KeyDefinition(label: 'tanh', action: InsertTemplate('tanh()', cursorOffset: 1)),
      KeyDefinition(label: 'coth', action: InsertTemplate('coth()', cursorOffset: 1)),
      KeyDefinition(label: 'sech', action: InsertTemplate('sech()', cursorOffset: 1)),
      KeyDefinition(label: 'csch', action: InsertTemplate('csch()', cursorOffset: 1)),
    ],
    [
      KeyDefinition(label: '□°□\'□"', action: InsertTemplate('°\'"', cursorOffset: 1)),
      KeyDefinition(label: 'arsinh', action: InsertTemplate('arsinh()', cursorOffset: 1)),
      KeyDefinition(label: 'arcosh', action: InsertTemplate('arcosh()', cursorOffset: 1)),
      KeyDefinition(label: 'artanh', action: InsertTemplate('artanh()', cursorOffset: 1)),
      KeyDefinition(label: 'arcoth', action: InsertTemplate('arcoth()', cursorOffset: 1)),
      KeyDefinition(label: 'arsech', action: InsertTemplate('arsech()', cursorOffset: 1)),
      KeyDefinition(label: 'arcsch', action: InsertTemplate('arcsch()', cursorOffset: 1)),
    ],
  ];

  // Calculus: 4 rows × 5 columns
  static const _limitsDiffInt = [
    [
      KeyDefinition(label: 'lim→', action: InsertTemplate('lim()', cursorOffset: 1)),
      KeyDefinition(label: 'd/dx', action: InsertTemplate('diff()', cursorOffset: 1)),
      KeyDefinition(label: '∫dx', action: InsertTemplate('int()', cursorOffset: 1)),
      KeyDefinition(label: 'dy/dx', action: InsertSymbol('dy/dx')),
      KeyDefinition(label: 'aₙ', action: InsertSymbol('a_n')),
    ],
    [
      KeyDefinition(label: 'lim⁺', action: InsertTemplate('lim_right()', cursorOffset: 1)),
      KeyDefinition(label: 'd²/dx²', action: InsertTemplate('diff2()', cursorOffset: 1)),
      KeyDefinition(label: '∫ₐᵇ', action: InsertTemplate('int_def()', cursorOffset: 1)),
      KeyDefinition(label: 'dx', action: InsertSymbol('dx')),
      KeyDefinition(label: '…', action: InsertSymbol('...')),
    ],
    [
      KeyDefinition(label: 'lim⁻', action: InsertTemplate('lim_left()', cursorOffset: 1)),
      KeyDefinition(label: 'dⁿ/dxⁿ', action: InsertTemplate('diff_n()', cursorOffset: 1)),
      KeyDefinition(label: '∫∫', action: InsertTemplate('int2()', cursorOffset: 1)),
      KeyDefinition(label: 'dy', action: InsertSymbol('dy')),
      KeyDefinition(label: 'Σ', action: InsertTemplate('sum()', cursorOffset: 1)),
    ],
    [
      KeyDefinition(label: '∞', action: InsertSymbol('∞')),
      KeyDefinition(label: "y'", action: InsertSymbol("y'")),
      KeyDefinition(label: 'Π', action: InsertTemplate('prod()', cursorOffset: 1)),
      KeyDefinition(label: '∂', action: InsertSymbol('∂')),
      KeyDefinition(label: '∇', action: InsertSymbol('∇')),
    ],
  ];

  static const _alphabet = [
    [
      KeyDefinition(label: 'a', action: InsertSymbol('a')),
      KeyDefinition(label: 'b', action: InsertSymbol('b')),
      KeyDefinition(label: 'c', action: InsertSymbol('c')),
      KeyDefinition(label: 'd', action: InsertSymbol('d')),
      KeyDefinition(label: 'e', action: InsertSymbol('e')),
      KeyDefinition(label: 'f', action: InsertSymbol('f')),
      KeyDefinition(label: 'g', action: InsertSymbol('g')),
      KeyDefinition(label: 'h', action: InsertSymbol('h')),
    ],
    [
      KeyDefinition(label: 'i', action: InsertSymbol('i')),
      KeyDefinition(label: 'j', action: InsertSymbol('j')),
      KeyDefinition(label: 'k', action: InsertSymbol('k')),
      KeyDefinition(label: 'l', action: InsertSymbol('l')),
      KeyDefinition(label: 'm', action: InsertSymbol('m')),
      KeyDefinition(label: 'n', action: InsertSymbol('n')),
      KeyDefinition(label: 'o', action: InsertSymbol('o')),
      KeyDefinition(label: 'p', action: InsertSymbol('p')),
    ],
    [
      KeyDefinition(label: 'q', action: InsertSymbol('q')),
      KeyDefinition(label: 'r', action: InsertSymbol('r')),
      KeyDefinition(label: 's', action: InsertSymbol('s')),
      KeyDefinition(label: 't', action: InsertSymbol('t')),
      KeyDefinition(label: 'u', action: InsertSymbol('u')),
      KeyDefinition(label: 'v', action: InsertSymbol('v')),
      KeyDefinition(label: 'w', action: InsertSymbol('w')),
      KeyDefinition(label: 'x', action: InsertSymbol('x')),
    ],
    [
      KeyDefinition(label: 'y', action: InsertSymbol('y')),
      KeyDefinition(label: 'z', action: InsertSymbol('z')),
      KeyDefinition(label: 'α', action: InsertSymbol('α')),
      KeyDefinition(label: 'β', action: InsertSymbol('β')),
      KeyDefinition(label: 'θ', action: InsertSymbol('θ')),
      KeyDefinition(label: 'ρ', action: InsertSymbol('ρ')),
      KeyDefinition(label: 'Φ', action: InsertSymbol('Φ')),
      KeyDefinition(label: '', action: InsertSymbol('')), // Spacer
    ],
  ];

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
