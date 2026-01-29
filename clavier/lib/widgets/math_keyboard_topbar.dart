import 'package:flutter/material.dart';
import '../constants/design_colors.dart';
import '../constants/design_spacing.dart';
import '../models/key_action.dart';
import '../models/keyboard_mode.dart'; // Maybe needed if we pass mode explicitly, but separate action is fine

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
          // ABC Toggle
          GestureDetector(
            onTap: () => onAction(const SwitchMode()),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'abc',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: DesignColors.primaryText,
                ),
              ),
            ),
          ),
          
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
