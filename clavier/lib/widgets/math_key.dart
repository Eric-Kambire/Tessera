import 'package:flutter/material.dart';
import '../constants/design_colors.dart';
import '../constants/design_spacing.dart';
import '../utils/keyboard_layouts.dart';

class MathKey extends StatefulWidget {
  final KeyDefinition definition;
  final VoidCallback onTap;

  const MathKey({
    super.key,
    required this.definition,
    required this.onTap,
  });

  @override
  State<MathKey> createState() => _MathKeyState();
}

class _MathKeyState extends State<MathKey> {
  bool _isPressed = false;
  OverlayEntry? _popupEntry;

  @override
  Widget build(BuildContext context) {
    final isHighlighted = widget.definition.isHighlighted;
    final isNumber = widget.definition.isNumber;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () {
        setState(() => _isPressed = false);
        _removePopup();
      },
      onTap: widget.onTap,
      onLongPress: widget.definition.hasVariants ? _showPopup : null,
      onLongPressUp: _removePopup,
      child: Container(
        decoration: BoxDecoration(
          color: isHighlighted
              ? DesignColors.keyBackground // Usually = has standard BG in some views, but let's keep it if highlighted requested
              : (_isPressed ? DesignColors.keyBackgroundPressed : DesignColors.keyBackground),
          borderRadius: BorderRadius.circular(DesignSpacing.keyRadius),
          border: Border.all(
            color: DesignColors.keyBorder,
            width: 1,
          ),
          // Floating effect (optional, subtle shadow)
          boxShadow: [
             BoxShadow(
              color: Colors.black.withOpacity(0.03),
              offset: const Offset(0, 2),
              blurRadius: 2,
             )
          ],
        ),
        alignment: Alignment.center,
        child: CustomPaint(
          foregroundPainter: widget.definition.hasVariants ? RedDotPainter() : null,
          child: Center(
            child: Text(
              widget.definition.label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: (isNumber || isHighlighted) ? FontWeight.w600 : FontWeight.w400,
                color: isHighlighted ? DesignColors.redAccent : DesignColors.primaryText, // "=" is usually Red text or Blue, or simple Black. User said "Photomath Red".
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showPopup() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    _popupEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Transparent detector to close? No, holding gesture controls usually
          Positioned(
            left: offset.dx - 10, // Slight visual offset
            top: offset.dy - 60, // Above the key
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: widget.definition.popupItems!.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        item,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_popupEntry!);
  }

  void _removePopup() {
    _popupEntry?.remove();
    _popupEntry = null;
  }
}

class RedDotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = DesignColors.redDot
      ..style = PaintingStyle.fill;

    // Bottom Right corner
    final dx = size.width - 6; // Padding
    final dy = size.height - 6;
    
    canvas.drawCircle(Offset(dx, dy), 2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
