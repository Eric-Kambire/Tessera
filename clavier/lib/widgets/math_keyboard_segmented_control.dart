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
        mainAxisAlignment: MainAxisAlignment.start, // Left aligned usually
        children: [
          _buildSegment(KeyboardMode.basicArithmetic, '+ - × ÷'),
          const SizedBox(width: 8),
          _buildSegment(KeyboardMode.functionsLog, 'f(x)'),
          const SizedBox(width: 8),
          _buildSegment(KeyboardMode.trigonometry, 'sin cos'),
          const SizedBox(width: 8),
          _buildSegment(KeyboardMode.limitsDiffInt, 'lim ∫'),
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
        height: DesignSpacing.segmentHeight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
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
          style: TextStyle(
            fontSize: 14,
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
