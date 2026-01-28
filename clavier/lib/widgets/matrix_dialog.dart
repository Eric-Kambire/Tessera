import 'package:flutter/material.dart';
import '../constants/design_colors.dart';
import '../constants/design_spacing.dart';

class MatrixDialog extends StatelessWidget {
  const MatrixDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignSpacing.modalRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             const Text(
              'Matrice',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            // Placeholders for Rows x Cols dropdowns
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text("3"),
                SizedBox(width: 8),
                Icon(Icons.close, size: 14),
                SizedBox(width: 8),
                Text("3"),
              ],
            ),
            const SizedBox(height: 20),
            // Placeholder for Grid Preview
            Container(
              height: 100,
              width: 100,
              color: Colors.grey.shade100,
              child: const Center(child: Text("Preview 5x5 Grid")),
            ),
             const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: DesignColors.primaryAction,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text("Incruster"),
            )
          ],
        ),
      ),
    );
  }
}
