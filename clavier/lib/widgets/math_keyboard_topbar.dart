import 'package:flutter/material.dart';
import '../constants/design_colors.dart';
import '../constants/design_spacing.dart';
import '../models/key_action.dart';

class MathKeyboardTopbar extends StatelessWidget {
  final ValueChanged<KeyAction> onAction;

  const MathKeyboardTopbar({super.key, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignSpacing.horizontalPadding,
        vertical: 8,
      ),
      child: Row(
        children: [
          // History / ABC
          _IconButton(icon: Icons.history, onTap: () {}), // Placeholder
          
          const Spacer(),

          // Center Controls (Undo, Cursor)
          _IconButton(icon: Icons.undo, onTap: () {}),
          const SizedBox(width: 8),
          _IconButton(icon: Icons.arrow_back_ios_new, size: 18, onTap: () => onAction(const MoveCursor(-1))),
          const SizedBox(width: 16),
          _IconButton(icon: Icons.arrow_forward_ios, size: 18, onTap: () => onAction(const MoveCursor(1))),
          const SizedBox(width: 8),
          _IconButton(icon: Icons.backspace_outlined, onTap: () => onAction(const DeleteChar())),
        ],
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;

  const _IconButton({required this.icon, required this.onTap, this.size = 22});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, size: size, color: DesignColors.primaryText),
      ),
    );
  }
}
