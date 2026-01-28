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

    return Column(
      children: layout.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: DesignSpacing.keySpacing),
          child: Row(
            children: row.map((keyDef) {
              // Exact distribution: 6 columns implies width/6.
              // Assuming uniform distribution for now for the 6-col grid logic
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.keySpacing / 2),
                  child: SizedBox(
                    height: DesignSpacing.keyHeight,
                    child: MathKey(
                      definition: keyDef,
                      onTap: () => onKeyAction(keyDef.action),
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
}
