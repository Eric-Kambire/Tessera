import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class MathKey extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? background;
  final Color? foreground;

  const MathKey({
    super.key,
    required this.label,
    required this.onTap,
    this.background,
    this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background ?? AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.neutralGray.withOpacity(0.2)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: foreground ?? AppColors.blackText,
          ),
        ),
      ),
    );
  }
}
