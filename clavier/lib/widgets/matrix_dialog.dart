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

            // 2. Dimension Selectors (Dropdown-like look)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDimensionBox(_rows, (val) => setState(() => _rows = val)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Icon(Icons.close, size: 14, color: Colors.grey[400]),
                ),
                _buildDimensionBox(_cols, (val) => setState(() => _cols = val)),
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
                  // Return the template string e.g. "matrix(3,3)"
                  Navigator.pop(context, widget.isDeterminant ? 'det($_rows,$_cols)' : 'mat($_rows,$_cols)');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC5093B), // Photomath deep red button
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

  Widget _buildDimensionBox(int value, Function(int) onChanged) {
    // Shows the dropdown visual (screenshot style: white box, grey border, red text)
    return Container(
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
              color: Color(0xFFC5093B), // Red text
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildGridPreview() {
    // The 5x5 grid select area
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Left Bracket/Bar
        _buildBracket(isLeft: true),
        
        const SizedBox(width: 8),

        // Grid
        Column(
          children: List.generate(_maxDim, (r) {
            return Row(
              children: List.generate(_maxDim, (c) {
                final int rowIdx = r + 1;
                final int colIdx = c + 1;
                final bool isSelected = rowIdx <= _rows && colIdx <= _cols;

                return GestureDetector(
                  onTap: () {
                    // Update dimensions based on tap
                    setState(() {
                      _rows = rowIdx;
                      _cols = colIdx;
                    });
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFC5093B) : Colors.transparent, // Red filled if selected
                      border: Border.all(
                        color: isSelected ? const Color(0xFFC5093B) : Colors.grey.shade300,
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

        // Right Bracket/Bar
        _buildBracket(isLeft: false),
      ],
    );
  }

  Widget _buildBracket({required bool isLeft}) {
    if (widget.isDeterminant) {
      // Just a vertical line
      return Container(
        width: 2,
        height: 180, // Approximate height of 5x5 grid
        color: Colors.black,
      );
    } else {
      // Square Bracket [ ]
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
      // [ shape
      path.moveTo(size.width, 0);
      path.lineTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      // ] shape
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
