import 'package:flutter/material.dart';
import '../constants/design_colors.dart';
import '../constants/design_spacing.dart';
import '../models/expression_state.dart';

class MathInputArea extends StatelessWidget {
  final ExpressionState state;

  const MathInputArea({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DesignSpacing.inputAreaPadding),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Simulated input field just for display
          Text(
            state.text.isEmpty ? 'Saisissez un problème...' : state.text,
            style: TextStyle(
              fontSize: 24,
              color: state.text.isEmpty 
                  ? DesignColors.placeholderText 
                  : DesignColors.primaryText,
              fontFamily: 'Roboto', // Default system font
            ),
          ),
          if (state.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                state.errorMessage!,
                style: const TextStyle(
                  color: DesignColors.primaryAction,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
