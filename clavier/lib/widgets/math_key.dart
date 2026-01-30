import 'package:flutter/material.dart';
import '../constants/design_colors.dart';
import '../constants/design_spacing.dart';
import '../utils/keyboard_layouts.dart';

class MathKey extends StatefulWidget {
  final KeyDefinition definition;
  final VoidCallback onTap;
  final ValueChanged<String>? onVariantSelected;

  const MathKey({
    super.key,
    required this.definition,
    required this.onTap,
    this.onVariantSelected,
  });

  @override
  State<MathKey> createState() => _MathKeyState();
}

class _MathKeyState extends State<MathKey> {
  bool _isPressed = false;
  OverlayEntry? _popupEntry;
  final ValueNotifier<int?> _selectedIndexNotifier = ValueNotifier<int?>(null);
  GlobalKey? _popupKey;

  @override
  void dispose() {
    _removePopup();
    _selectedIndexNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isHighlighted = widget.definition.isHighlighted;
    final isNumber = widget.definition.isNumber;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _removePopup();
      },
      onLongPressStart: (details) {
        if (widget.definition.hasVariants) {
          setState(() => _isPressed = true);
          _showPopup();
        }
      },
      onLongPressMoveUpdate: (details) {
        if (_popupEntry != null) {
          _updatePopupSelection(details.globalPosition);
        }
      },
      onLongPressEnd: (details) {
        setState(() => _isPressed = false);
        _finalizeSelection();
      },
      onLongPressUp: () { // Should be covered by LongPressEnd but good for safety
         setState(() => _isPressed = false);
         _finalizeSelection();
      },
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
            child: _buildLabel(isNumber, isHighlighted),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(bool isNumber, bool isHighlighted) {
    if (widget.definition.label == '□/□') {
      return const FractionIcon();
    }
    // Add other custom icons here if needed
    
    return Text(
      widget.definition.label,
      style: TextStyle(
        fontSize: 20,
        fontWeight: (isNumber || isHighlighted) ? FontWeight.w600 : FontWeight.w400,
        color: isHighlighted ? DesignColors.redAccent : DesignColors.primaryText,
      ),
    );
  }

  void _showPopup() {
    _popupKey = GlobalKey();
    _selectedIndexNotifier.value = null; // Reset selection

    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    final keyWidth = renderBox.size.width;

    // Calculate popup width rough estimate to center it
    final itemCount = widget.definition.popupItems!.length;
    final estimatedWidth = itemCount * 40.0 + 16.0; // 40 per item + padding
    final dx = offset.dx + (keyWidth / 2) - (estimatedWidth / 2);
    final dy = offset.dy - 60; // Above the key

    _popupEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned(
            left: dx.clamp(10.0, MediaQuery.of(context).size.width - estimatedWidth - 10), // Prevent overflow
            top: dy,
            child: PopupMenu(
              key: _popupKey,
              items: widget.definition.popupItems!,
              selectedIndexNotifier: _selectedIndexNotifier,
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_popupEntry!);
  }

  void _updatePopupSelection(Offset globalPosition) {
    if (_popupKey?.currentContext == null) return;

    final RenderBox popupBox = _popupKey!.currentContext!.findRenderObject() as RenderBox;
    final localPos = popupBox.globalToLocal(globalPosition);

    // Assuming Row layout in PopupMenu
    // We need to know where the items are.
    // Simplifying: dividing width by count.
    
    final width = popupBox.size.width;
    final itemCount = widget.definition.popupItems!.length;
    final itemWidth = width / itemCount;

    if (localPos.dy < -20 || localPos.dy > popupBox.size.height + 20) {
      _selectedIndexNotifier.value = null;
      return;
    }
    
    if (localPos.dx >= 0 && localPos.dx <= width) {
        int index = (localPos.dx / itemWidth).floor();
        if (index >= 0 && index < itemCount) {
           _selectedIndexNotifier.value = index;
           return;
        }
    }
    _selectedIndexNotifier.value = null;
  }

  void _finalizeSelection() {
    if (_popupEntry == null) return;
    
    final index = _selectedIndexNotifier.value;
    if (index != null && index >= 0 && index < widget.definition.popupItems!.length) {
       final selectedLabel = widget.definition.popupItems![index];
       widget.onVariantSelected?.call(selectedLabel);
    }
    _removePopup();
  }

  void _removePopup() {
    _popupEntry?.remove();
    _popupEntry = null;
  }
}

class PopupMenu extends StatelessWidget {
  final List<String> items;
  final ValueNotifier<int?> selectedIndexNotifier;

  const PopupMenu({
    super.key,
    required this.items,
    required this.selectedIndexNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: ValueListenableBuilder<int?>(
          valueListenable: selectedIndexNotifier,
          builder: (context, selectedIndex, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(items.length, (index) {
                 final isSelected = index == selectedIndex;
                 return Container(
                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                   decoration: BoxDecoration(
                     color: isSelected ? DesignColors.keyBackgroundPressed : Colors.transparent,
                     borderRadius: BorderRadius.circular(8),
                   ),
                   child: Text(
                     items[index],
                     style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                   ),
                 );
              }),
            );
          },
        ),
      ),
    );
  }
}

class RedDotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = DesignColors.redDot
      ..style = PaintingStyle.fill;
    final dx = size.width - 6;
    final dy = size.height - 6;
    canvas.drawCircle(Offset(dx, dy), 2, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FractionIcon extends StatelessWidget {
  const FractionIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(20, 20),
      painter: FractionIconPainter(),
    );
  }
}

class FractionIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = DesignColors.primaryText
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final boxPaint = Paint()
      ..color = DesignColors.placeholderText // Grey color for boxes
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Center point
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Horizontal line
    canvas.drawLine(Offset(0, cy), Offset(size.width, cy), paint);

    // Top Box
    final boxSize = Size(10, 8);
    final topBoxRect = Rect.fromCenter(center: Offset(cx, cy - 6), width: boxSize.width, height: boxSize.height);
    canvas.drawRect(topBoxRect, boxPaint);

    // Bottom Box
    final bottomBoxRect = Rect.fromCenter(center: Offset(cx, cy + 6), width: boxSize.width, height: boxSize.height);
    canvas.drawRect(bottomBoxRect, boxPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
