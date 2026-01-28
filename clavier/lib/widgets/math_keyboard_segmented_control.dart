import 'package:flutter/material.dart';
import '../constants/design_colors.dart';
import '../constants/design_spacing.dart';
import '../models/keyboard_mode.dart';

class MathKeyboardSegmentedControl extends StatelessWidget {
  final KeyboardMode currentMode;
  final ValueChanged<KeyboardMode> onModeChanged;

  const MathKeyboardSegmentedControl({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: DesignSpacing.segmentHeight,
      margin: const EdgeInsets.symmetric(horizontal: DesignSpacing.horizontalPadding),
      decoration: BoxDecoration(
        color: DesignColors.segmentInactive,
        borderRadius: BorderRadius.circular(DesignSpacing.segmentRadius),
        border: Border.all(color: DesignColors.keyBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Hug content (centered usually)
        children: [
          _buildSegment(context, KeyboardMode.basicArithmetic, '+ - × ÷'),
          _buildSegment(context, KeyboardMode.functionsLog, 'f(x)'),
          _buildSegment(context, KeyboardMode.trigonometry, 'sin cos'),
          _buildSegment(context, KeyboardMode.limitsDiffInt, 'lim ∫'),
          _buildSegment(context, KeyboardMode.alphabet, 'abc'),
        ],
      ),
    );
  }

  Widget _buildSegment(BuildContext context, KeyboardMode mode, String label) {
    final isSelected = currentMode == mode;
    return GestureDetector(
      onTap: () => onModeChanged(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? DesignColors.segmentActive : Colors.transparent,
          borderRadius: BorderRadius.circular(DesignSpacing.segmentRadius),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected 
                ? DesignColors.segmentActiveText 
                : DesignColors.segmentInactiveText,
          ),
        ),
      ),
    );
  }
}
