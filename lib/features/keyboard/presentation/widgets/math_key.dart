import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class MathKey extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? background;
  final Color? foreground;
  final bool showDot;
  final double scale;

  const MathKey({
    super.key,
    required this.label,
    this.onTap,
    this.onLongPress,
    this.background,
    this.foreground,
    this.showDot = false,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) {
      return const SizedBox.shrink();
    }

    final baseColor = foreground ?? AppColors.blackText;

    final clampedScale = scale.clamp(0.85, 1.05);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(8),
        splashColor: AppColors.primaryBlue.withOpacity(0.16),
        highlightColor: AppColors.primaryBlue.withOpacity(0.08),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(4 * clampedScale),
          decoration: BoxDecoration(
            color: background ?? AppColors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.neutralGray.withOpacity(0.18), width: 0.5),
          ),
          child: Stack(
            children: [
              Center(child: _LabelText(label: label, color: baseColor, scale: clampedScale)),
              if (showDot)
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 4 * clampedScale,
                    height: 4 * clampedScale,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF3B30),
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

class _LabelText extends StatelessWidget {
  final String label;
  final Color color;
  final double scale;

  const _LabelText({required this.label, required this.color, required this.scale});

  @override
  Widget build(BuildContext context) {
    final parts = label.split('');
    final hasPlaceholder = parts.contains('□');

    final baseStyle = TextStyle(
      fontSize: (_isNumeric(label) ? 16 : 14) * scale,
      fontWeight: _isNumeric(label) ? FontWeight.w600 : FontWeight.w400,
      color: color,
      height: 1.05,
      letterSpacing: 0.2 * scale,
    );

    if (!hasPlaceholder) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(label, style: baseStyle, textAlign: TextAlign.center),
      );
    }

    final spans = <InlineSpan>[];
    for (final ch in parts) {
      if (ch == '□') {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: _PlaceholderBox(scale: scale),
            ),
          ),
        );
      } else {
        spans.add(TextSpan(text: ch, style: baseStyle));
      }
    }

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text.rich(
        TextSpan(children: spans),
        textAlign: TextAlign.center,
      ),
    );
  }

  bool _isNumeric(String value) {
    return RegExp(r'^[0-9]$').hasMatch(value) || value == '.' || value == ',';
  }
}

class _PlaceholderBox extends StatelessWidget {
  final double scale;

  const _PlaceholderBox({required this.scale});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(11 * scale, 11 * scale),
      painter: _DashedBoxPainter(color: const Color(0xFF999999)),
    );
  }
}

class _DashedBoxPainter extends CustomPainter {
  final Color color;

  const _DashedBoxPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dashWidth = 2.0;
    const dashSpace = 2.0;

    void drawDashedLine(Offset start, Offset end) {
      final total = (end - start).distance;
      final direction = (end - start) / total;
      var distance = 0.0;
      while (distance < total) {
        final current = start + direction * distance;
        final next = start + direction * (distance + dashWidth).clamp(0, total);
        canvas.drawLine(current, next, paint);
        distance += dashWidth + dashSpace;
      }
    }

    drawDashedLine(const Offset(0, 0), Offset(size.width, 0));
    drawDashedLine(Offset(size.width, 0), Offset(size.width, size.height));
    drawDashedLine(Offset(size.width, size.height), Offset(0, size.height));
    drawDashedLine(Offset(0, size.height), const Offset(0, 0));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
