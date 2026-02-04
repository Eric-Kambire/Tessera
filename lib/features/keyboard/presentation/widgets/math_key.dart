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
    final displayLabel = _normalizeLabel(label);

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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Center(child: _LabelText(label: displayLabel, color: baseColor, scale: clampedScale)),
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
    if (label == '□/□') {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: _FractionKeyLabel(color: color, scale: scale),
      );
    }
    if (label.startsWith('lim')) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: _LimitKeyLabel(label: label, color: color, scale: scale),
      );
    }
    if (_looksLikeSqrt(label)) {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: _SqrtKeyLabel(color: color, scale: scale),
      );
    }
    if (label == '□²' || label == '□³' || label == '□ⁿ') {
      return FittedBox(
        fit: BoxFit.scaleDown,
        child: _PowerKeyLabel(label: label, color: color, scale: scale),
      );
    }

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

  bool _looksLikeSqrt(String value) {
    return value.contains('√') && value.contains('□');
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

class _FractionKeyLabel extends StatelessWidget {
  final Color color;
  final double scale;

  const _FractionKeyLabel({required this.color, required this.scale});

  @override
  Widget build(BuildContext context) {
    final lineColor = color.withOpacity(0.9);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PlaceholderBox(scale: scale),
        Container(
          margin: EdgeInsets.symmetric(vertical: 2 * scale),
          width: 16 * scale,
          height: 1.2 * scale,
          color: lineColor,
        ),
        _PlaceholderBox(scale: scale),
      ],
    );
  }
}

class _SqrtKeyLabel extends StatelessWidget {
  final Color color;
  final double scale;

  const _SqrtKeyLabel({required this.color, required this.scale});

  @override
  Widget build(BuildContext context) {
    final box = _PlaceholderBox(scale: scale);
    final barThickness = 1.2 * scale;
    final barWidth = 14 * scale;
    return SizedBox(
      height: 22 * scale,
      child: Align(
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '√',
              style: TextStyle(
                fontSize: 18 * scale,
                fontWeight: FontWeight.w600,
                color: color,
                height: 1.2,
              ),
            ),
            // Overlap the bar slightly onto the radical to visually connect it.
            Transform.translate(
              offset: Offset(-1 * scale, 0),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topLeft,
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: barWidth,
                      height: barThickness,
                      color: color,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 3 * scale),
                    child: box,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PowerKeyLabel extends StatelessWidget {
  final String label;
  final Color color;
  final double scale;

  const _PowerKeyLabel({required this.label, required this.color, required this.scale});

  @override
  Widget build(BuildContext context) {
    final exp = label.replaceAll('□', '');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PlaceholderBox(scale: scale),
        Padding(
          padding: EdgeInsets.only(left: 2 * scale, bottom: 6 * scale),
          child: Text(
            exp,
            style: TextStyle(fontSize: 10 * scale, fontWeight: FontWeight.w600, color: color),
          ),
        ),
      ],
    );
  }
}

String _normalizeLabel(String input) {
  var out = input;
  out = out.replaceAll('â–¡', '□');
  out = out.replaceAll('âˆš', '√');
  out = out.replaceAll('Ã—', '×');
  out = out.replaceAll('Ã·', '÷');
  out = out.replaceAll('âˆ’', '−');
  out = out.replaceAll('Ï€', 'π');
  out = out.replaceAll('Â²', '²');
  out = out.replaceAll('Â³', '³');
  out = out.replaceAll('â¿', 'ⁿ');
  out = out.replaceAll('â†’', '→');
  out = out.replaceAll('âˆž', '∞');
  return out;
}

class _LimitKeyLabel extends StatelessWidget {
  final String label;
  final Color color;
  final double scale;

  const _LimitKeyLabel({required this.label, required this.color, required this.scale});

  @override
  Widget build(BuildContext context) {
    final hasPlus = label.contains('+');
    final hasMinus = label.contains('−');
    final hasInfinity = label.contains('∞');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('lim', style: TextStyle(fontSize: 13 * scale, fontWeight: FontWeight.w600, color: color)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PlaceholderBox(scale: scale),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2 * scale),
              child: Text('→', style: TextStyle(fontSize: 11 * scale, color: color)),
            ),
            if (hasInfinity) Text('∞', style: TextStyle(fontSize: 11 * scale, color: color)),
            if (!hasInfinity) _PlaceholderBox(scale: scale),
            if (hasPlus || hasMinus)
              Padding(
                padding: EdgeInsets.only(left: 1 * scale, bottom: 4 * scale),
                child: Text(hasPlus ? '+' : '−', style: TextStyle(fontSize: 9 * scale, color: color)),
              ),
          ],
        ),
      ],
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
