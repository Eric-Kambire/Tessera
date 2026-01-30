import 'package:flutter/material.dart';
import '../constants/design_colors.dart';
import '../constants/design_spacing.dart';

class MatrixDialog extends StatefulWidget {
  final bool isDeterminant; // Toggle between Matrix [] and Determinant ||

  const MatrixDialog({super.key, this.isDeterminant = false});

  @override
  State<MatrixDialog> createState() => _MatrixDialogState();
}

class _MatrixDialogState extends State<MatrixDialog> {
  int _rows = 3;
  int _cols = 3;
  final int _maxDim = 5;

  @override
  void initState() {
    super.initState();
    // For determinant, force square matrix
    if (widget.isDeterminant) {
      _cols = _rows;
    }
  }

  void _setRows(int val) {
    setState(() {
      _rows = val;
      if (widget.isDeterminant) {
        _cols = val;
      }
    });
  }

  void _setCols(int val) {
    setState(() {
      _cols = val;
      if (widget.isDeterminant) {
        _rows = val;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSpacing.modalRadius),
      ),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Title
            Text(
              widget.isDeterminant ? 'Déterminants' : 'Matrices',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 16),

            // 2. Dimension Selectors (Functional dropdowns)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDimensionDropdown(_rows, _setRows),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Icon(Icons.close, size: 14, color: Colors.grey[400]),
                ),
                _buildDimensionDropdown(_cols, _setCols),
              ],
            ),

            const SizedBox(height: 24),

            // 3. The Grid Preview
            _buildGridPreview(),

            const SizedBox(height: 24),

            // 4. Action Button "Incruster"
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, widget.isDeterminant ? 'det($_rows,$_cols)' : 'mat($_rows,$_cols)');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: DesignColors.redAccent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text("Incruster"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDimensionDropdown(int value, Function(int) onChanged) {
    return PopupMenuButton<int>(
      onSelected: onChanged,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      itemBuilder: (context) {
        return List.generate(_maxDim, (i) {
          final dim = i + 1;
          return PopupMenuItem<int>(
            value: dim,
            child: Text(
              '$dim',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: dim == value ? DesignColors.redAccent : Colors.black,
              ),
            ),
          );
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$value',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: DesignColors.redAccent,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildGridPreview() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildBracket(isLeft: true),

        const SizedBox(width: 8),

        Column(
          children: List.generate(_maxDim, (r) {
            return Row(
              children: List.generate(_maxDim, (c) {
                final int rowIdx = r + 1;
                final int colIdx = c + 1;
                final bool isSelected = rowIdx <= _rows && colIdx <= _cols;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _rows = rowIdx;
                      _cols = colIdx;
                      if (widget.isDeterminant) {
                        // For determinant, use the max of row/col to keep square
                        final dim = rowIdx > colIdx ? rowIdx : colIdx;
                        _rows = dim;
                        _cols = dim;
                      }
                    });
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected ? DesignColors.redAccent : Colors.transparent,
                      border: Border.all(
                        color: isSelected ? DesignColors.redAccent : Colors.grey.shade300,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            );
          }),
        ),

        const SizedBox(width: 8),

        _buildBracket(isLeft: false),
      ],
    );
  }

  Widget _buildBracket({required bool isLeft}) {
    if (widget.isDeterminant) {
      return Container(
        width: 2,
        height: 180,
        color: Colors.black,
      );
    } else {
      return SizedBox(
        height: 180,
        width: 10,
        child: CustomPaint(
          painter: BracketPainter(isLeft: isLeft),
        ),
      );
    }
  }
}

class BracketPainter extends CustomPainter {
  final bool isLeft;
  BracketPainter({required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;

    final path = Path();
    if (isLeft) {
      path.moveTo(size.width, 0);
      path.lineTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
