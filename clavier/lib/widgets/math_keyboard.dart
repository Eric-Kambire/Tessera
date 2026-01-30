import 'package:flutter/material.dart';
import '../models/keyboard_mode.dart';
import '../models/key_action.dart';
import '../utils/keyboard_layouts.dart';
import '../constants/design_spacing.dart';
import 'math_key.dart';

class MathKeyboard extends StatelessWidget {
  final KeyboardMode mode;
  final ValueChanged<KeyAction> onKeyAction;

  const MathKeyboard({
    super.key,
    required this.mode,
    required this.onKeyAction,
  });

  @override
  Widget build(BuildContext context) {
    final layout = KeyboardLayouts.getLayout(mode);
    final colCount = KeyboardLayouts.getColumnCount(mode);

    // For trigonometry (7 cols), wrap in horizontal scroll
    if (mode == KeyboardMode.trigonometry) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: colCount * 80.0, // Fixed width per key for trig
          child: _buildGrid(layout),
        ),
      );
    }

    return _buildGrid(layout);
  }

  Widget _buildGrid(List<List<KeyDefinition>> layout) {
    return Column(
      children: layout.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: DesignSpacing.keySpacing),
          child: Row(
            children: row.map((keyDef) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.keySpacing / 2),
                  child: SizedBox(
                    height: DesignSpacing.keyHeight,
                    child: MathKey(
                      definition: keyDef,
                      onTap: () => onKeyAction(keyDef.action),
                      onVariantSelected: (variant) => _handleVariant(variant, onKeyAction),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  void _handleVariant(String variant, ValueChanged<KeyAction> onAction) {
    // Variable mappings
    if (['x', 'y', 'z', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm',
         'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'α', 'β', 'θ', 'ρ', 'Φ'].contains(variant)) {
      onAction(InsertSymbol(variant));
      return;
    }

    // Comparison operators
    if (['>', '<', '≥', '≤', '=', '≠'].contains(variant)) {
      onAction(InsertSymbol(variant));
      return;
    }

    // Constants
    if (['π', 'e', 'φ', 'i'].contains(variant)) {
      onAction(InsertSymbol(variant));
      return;
    }

    // Pi fractions from popup
    if (variant == 'π/2') {
      onAction(const InsertSymbol('π/2'));
      return;
    }
    if (variant == 'π/3') {
      onAction(const InsertSymbol('π/3'));
      return;
    }

    // Specific Template Variants
    switch (variant) {
      case '□/□':
        onAction(const InsertTemplate('/', cursorOffset: 1));
        break;
      case '□(□/□)':
        onAction(const InsertTemplate('mixed_fraction', cursorOffset: 1));
        break;
      case '√':
        onAction(const InsertTemplate('sqrt()', cursorOffset: 1));
        break;
      case '∛':
        onAction(const InsertTemplate('nroot(3)', cursorOffset: 1));
        break;
      case 'ⁿ√':
        onAction(const InsertTemplate('nroot()', cursorOffset: 1));
        break;
      case '□²':
        onAction(const InsertTemplate('^2', cursorOffset: 0));
        break;
      case '□³':
        onAction(const InsertTemplate('^3', cursorOffset: 0));
        break;
      case '□ⁿ':
        onAction(const InsertTemplate('^', cursorOffset: 1));
        break;
      default:
        onAction(InsertSymbol(variant));
    }
  }
}
