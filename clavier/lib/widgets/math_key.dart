import 'package:flutter/material.dart';
import '../constants/design_colors.dart';
import '../constants/design_spacing.dart';
import '../utils/keyboard_layouts.dart';
import '../models/key_action.dart';

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

  @override
  Widget build(BuildContext context) {
    final isHighlighted = widget.definition.isHighlighted;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      onLongPress: widget.definition.popupItems != null 
          ? () => _showPopup(context) 
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: isHighlighted 
              ? DesignColors.primaryAction 
              : (_isPressed ? DesignColors.keyPressed : DesignColors.keyBackground),
          borderRadius: BorderRadius.circular(DesignSpacing.keyRadius),
          border: Border.all(
            color: isHighlighted ? DesignColors.primaryAction : DesignColors.keyBorder,
            width: 1,
          ),
          boxShadow: isHighlighted ? [] : [
             BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 1),
              blurRadius: 1,
             )
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          widget.definition.label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
            color: isHighlighted ? Colors.white : DesignColors.primaryText,
          ),
        ),
      ),
    );
  }

  void _showPopup(BuildContext context) async {
    // Basic popup implementation - for production would use a specific OverlayEntry
    // mimicking Photomath's horizontal popup
    final items = widget.definition.popupItems!;
    
    // This is a simplified simulation of the popup selection
    // In a real app, you'd calculate position and show a custom widget overlay
    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text('Select option'),
        children: items.map((e) => SimpleDialogOption(
          onPressed: () => Navigator.pop(ctx, e),
          child: Text(e, style: const TextStyle(fontSize: 18)),
        )).toList(),
      ),
    );

    if (selected != null) {
      // Handle the variant selection (simplified logic here)
      widget.onTap(); // In reality, we'd pass the variant
    }
  }
}
