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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.horizontalPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildSegment(KeyboardMode.basicArithmetic, '+ −\n× ÷'),
          const SizedBox(width: 8),
          _buildSegment(KeyboardMode.functionsLog, 'f(x) e\nlog ln'),
          const SizedBox(width: 8),
          _buildSegment(KeyboardMode.trigonometry, 'sin cos\ntan cot'),
          const SizedBox(width: 8),
          _buildSegment(KeyboardMode.limitsDiffInt, 'lim dx\n∫ Σ ∞'),
        ],
      ),
    );
  }

  Widget _buildSegment(KeyboardMode mode, String label) {
    final isSelected = currentMode == mode;
    return GestureDetector(
      onTap: () => onModeChanged(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? DesignColors.segmentActiveBackground : Colors.white,
          borderRadius: BorderRadius.circular(DesignSpacing.segmentRadius),
          border: isSelected
              ? null
              : Border.all(color: DesignColors.segmentBorder),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            height: 1.3,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? DesignColors.segmentActiveText
                : DesignColors.segmentInactiveText,
          ),
        ),
      ),
    );
  }
}
