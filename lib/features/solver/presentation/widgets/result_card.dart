import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/latex_view.dart';
import '../../domain/entities/math_solution.dart';

class ResultCard extends StatelessWidget {
  final MathSolution solution;

  const ResultCard({super.key, required this.solution});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBlue.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.secondaryGreen,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resultat final',
                  style: TextStyle(color: AppColors.neutralGray, fontSize: 12),
                ),
                const SizedBox(height: 6),
                LatexView(
                  latex: solution.finalAnswerLatex,
                  textStyle: Theme.of(context).textTheme.titleLarge,
                ),
                if (_hasAlt(solution.finalAnswerLatex)) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Forme alternative',
                    style: const TextStyle(color: AppColors.neutralGray, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  LatexView(latex: solution.finalAnswerLatex),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _hasAlt(String latex) {
    return latex.contains('\\frac') || latex.contains('/');
  }
}
