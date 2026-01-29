import 'package:flutter/material.dart';
import '../constants/design_colors.dart';
import '../constants/design_spacing.dart';
import '../models/expression_state.dart';
import '../models/key_action.dart';
import '../models/keyboard_mode.dart';
import 'math_input_area.dart';
import 'math_keyboard_topbar.dart';
import 'math_keyboard_segmented_control.dart';
import 'math_keyboard.dart';
import 'matrix_dialog.dart';

class MathKeyboardSheet extends StatefulWidget {
  final Function(String) onExpressionChanged;
  final VoidCallback onClose;

  const MathKeyboardSheet({
    super.key,
    required this.onExpressionChanged,
    required this.onClose,
  });

  @override
  State<MathKeyboardSheet> createState() => _MathKeyboardSheetState();
}

class _MathKeyboardSheetState extends State<MathKeyboardSheet> {
  KeyboardMode _mode = KeyboardMode.basicArithmetic;
  ExpressionState _state = const ExpressionState();



  void _handleKeyAction(KeyAction action) {
    setState(() {
      switch (action) {
        case InsertSymbol(symbol: final s):
          _state = _state.copyWith(text: _state.text + s);
          break;
        case InsertTemplate(template: final t, cursorOffset: final offset):
           _state = _state.copyWith(
             text: _state.text + t,
             cursorPosition: _state.cursorPosition + t.length - offset, // Approximation
           );
           break;
        case DeleteChar():
          if (_state.text.isNotEmpty) {
            _state = _state.copyWith(text: _state.text.substring(0, _state.text.length - 1));
          }
          break;
        case ClearExpression():
          _state = _state.copyWith(text: '');
          break;
        case MoveCursor(offset: final o):
          // Simple bounds check
          final newPos = (_state.cursorPosition + o).clamp(0, _state.text.length);
          _state = _state.copyWith(cursorPosition: newPos);
          break;
        case OpenModal(modalType: final type):
          if (type == 'matrix') {
             // Defer UI call to post-build or allow here since it's a callback
             Future.microtask(() => showDialog(
               context: context,
               builder: (_) => const MatrixDialog(),
             ));
          }
          break;
        case EvaluateExpression():
          // TODO: Trigger calculation
          print("Calculating: ${_state.text}");
          break;
        default: break;
      }
    });
    widget.onExpressionChanged(_state.text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DesignColors.scaffoldBackground, // Slightly off-white
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(), // White header
          
          Container(
            color: Colors.white,
            child: MathInputArea(state: _state),
          ),
          
          // Divider or Shadow
          Container(height: 1, color: DesignColors.keyBorder),

          // Keyboard Controls
          Container(
            color: DesignColors.scaffoldBackground,
            child: Column(
              children: [
                MathKeyboardTopbar(onAction: _handleKeyAction),
                
                const SizedBox(height: 4),
                
                MathKeyboardSegmentedControl(
                  currentMode: _mode,
                  onModeChanged: (m) => setState(() => _mode = m),
                ),
                
                const SizedBox(height: 12),

                // Main Grid
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignSpacing.horizontalPadding,
                  ),
                  child: MathKeyboard(
                    mode: _mode,
                    onKeyAction: _handleKeyAction,
                  ),
                ),
                
                SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Calculateur',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: DesignColors.primaryText,
            ),
          ),
          GestureDetector(
             onTap: widget.onClose,
            child: const Icon(Icons.keyboard_arrow_down, size: 28, color: DesignColors.secondaryText),
          ),
        ],
      ),
    );
  }
}
