import 'package:flutter/material.dart';
import '../constants/design_colors.dart';
import '../models/expression_state.dart';
import '../models/key_action.dart';
import '../models/keyboard_mode.dart';
import 'math_input_area.dart';
import 'math_keyboard_topbar.dart';
import 'math_keyboard_segmented_control.dart';
import 'math_keyboard.dart';

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
        case InsertTemplate(template: final t):
           _state = _state.copyWith(text: _state.text + t);
           break;
        case DeleteChar():
          if (_state.text.isNotEmpty) {
            _state = _state.copyWith(text: _state.text.substring(0, _state.text.length - 1));
          }
          break;
        case ClearExpression():
          _state = _state.copyWith(text: '');
          break;
        case EvaluateExpression():
          // Trigger solve (simulated)
          break;
        default:
          break;
      }
    });

    widget.onExpressionChanged(_state.text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: DesignColors.sheetBackground,
      child: Column(
        mainAxisSize: MainAxisSize.min, // Sheet behavior
        children: [
          // Header
          _buildHeader(),
          
          Divider(height: 1, color: DesignColors.divider),
          
          // Input Area
          MathInputArea(state: _state),

          Divider(height: 1, color: DesignColors.divider),

          // Keyboard Controls
          MathKeyboardTopbar(onAction: _handleKeyAction),
          
          Center(
            child: MathKeyboardSegmentedControl(
              currentMode: _mode,
              onModeChanged: (m) => setState(() => _mode = m),
            ),
          ),
          
          const SizedBox(height: 12),

          // Main Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0), // Outer margin for grid
            child: MathKeyboard(
              mode: _mode,
              onKeyAction: _handleKeyAction,
            ),
          ),
          
          // Bottom Safe Area
          SizedBox(height: MediaQuery.of(context).padding.bottom + 10), 
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
          TextButton(
            onPressed: widget.onClose,
            child: const Text('Fermer', style: TextStyle(color: DesignColors.primaryAction)),
          ),
        ],
      ),
    );
  }
}
