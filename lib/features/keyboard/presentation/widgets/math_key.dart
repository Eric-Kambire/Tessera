import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class MathKey extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? background;
  final Color? foreground;
  final bool showDot;

  const MathKey({
    super.key,
    required this.label,
    required this.onTap,
    this.background,
    this.foreground,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        splashColor: AppColors.primaryBlue.withOpacity(0.18),
        highlightColor: AppColors.primaryBlue.withOpacity(0.08),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: background ?? AppColors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.neutralGray.withOpacity(0.25), width: 0.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: foreground ?? AppColors.blackText,
                  ),
                ),
              ),
              if (showDot)
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE04747),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
