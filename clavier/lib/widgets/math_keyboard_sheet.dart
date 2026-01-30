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
  final List<ExpressionState> _history = [];

  bool get _isAlphabetMode => _mode == KeyboardMode.alphabet;

  void _saveHistory() {
    _history.add(_state);
    // Keep history bounded
    if (_history.length > 100) {
      _history.removeAt(0);
    }
  }

  void _handleKeyAction(KeyAction action) {
    setState(() {
      switch (action) {
        case InsertSymbol(symbol: final s):
          _saveHistory();
          _state = _state.copyWith(text: _state.text + s);
          break;
        case InsertTemplate(template: final t, cursorOffset: final offset):
           _saveHistory();
           // Map templates to visual representations if needed
           String visual = t;
           int derivedOffset = offset;

           if (t == '/') { visual = '□/□'; derivedOffset = 2; }
           else if (t == 'sqrt()') { visual = '√□'; derivedOffset = 0; }

           if (t == '/') {
             visual = '□ / □';
             derivedOffset = 4;
           } else if (t == 'sqrt()') {
             visual = '√□';
             derivedOffset = 1;
           }

           _state = _state.copyWith(
             text: _state.text + visual,
             cursorPosition: (_state.cursorPosition + visual.length - derivedOffset).clamp(0, _state.text.length + visual.length),
           );
           break;
        case InsertCode(code: final c):
           _saveHistory();
           _state = _state.copyWith(text: _state.text + c);
           break;
        case SwitchMode():
           setState(() {
             _mode = _isAlphabetMode ? KeyboardMode.basicArithmetic : KeyboardMode.alphabet;
           });
           break;
        case DeleteChar():
          if (_state.text.isNotEmpty) {
            _saveHistory();
            _state = _state.copyWith(text: _state.text.substring(0, _state.text.length - 1));
          }
          break;
        case ClearExpression():
          _saveHistory();
          _state = _state.copyWith(text: '');
          break;
        case MoveCursor(offset: final o):
          final newPos = (_state.cursorPosition + o).clamp(0, _state.text.length);
          _state = _state.copyWith(cursorPosition: newPos);
          break;
        case NewLine():
          _saveHistory();
          _state = _state.copyWith(text: '${_state.text}\n');
          break;
        case Undo():
          if (_history.isNotEmpty) {
            _state = _history.removeLast();
          }
          break;
        case OpenModal(modalType: final type):
             Future.microtask(() => showDialog(
               context: context,
               builder: (_) => MatrixDialog(
                 isDeterminant: type == 'determinant',
               ),
             ));
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
      color: DesignColors.scaffoldBackground,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),

          Container(
            color: Colors.white,
            child: MathInputArea(state: _state),
          ),

          Container(height: 1, color: DesignColors.keyBorder),

          Container(
            color: DesignColors.scaffoldBackground,
            child: Column(
              children: [
                MathKeyboardTopbar(
                  onAction: _handleKeyAction,
                  isAlphabetMode: _isAlphabetMode,
                ),

                const SizedBox(height: 4),

                MathKeyboardSegmentedControl(
                  currentMode: _mode,
                  onModeChanged: (m) => setState(() => _mode = m),
                ),

                const SizedBox(height: 12),

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
