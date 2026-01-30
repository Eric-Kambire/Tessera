import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/latex_view.dart';
import '../../domain/entities/solution_step.dart';

class StepCard extends StatelessWidget {
  final SolutionStep step;
  final double indent;

  const StepCard({super.key, required this.step, this.indent = 0});

  @override
  Widget build(BuildContext context) {
    final card = Padding(
      padding: EdgeInsets.only(left: indent),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primaryBlue.withOpacity(0.08)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    _Dot(color: AppColors.primaryBlue),
                    SizedBox(width: 8),
                    Text('Input', style: TextStyle(color: AppColors.neutralGray)),
                  ],
                ),
                const SizedBox(height: 6),
                LatexView(latex: step.inputLatex),
                const SizedBox(height: 10),
                Text(
                  step.description,
                  style: const TextStyle(color: AppColors.neutralGray),
                ),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    _Dot(color: AppColors.secondaryGreen),
                    SizedBox(width: 8),
                    Text('Output', style: TextStyle(color: AppColors.neutralGray)),
                  ],
                ),
                const SizedBox(height: 6),
                LatexView(latex: step.outputLatex),
              ],
            ),
          ),
        ),
      ),
    );

    if (step.subSteps.isEmpty) {
      return card;
    }

    return ExpansionTile(
      tilePadding: EdgeInsets.only(left: indent),
      title: Text(step.description, style: const TextStyle(color: AppColors.neutralGray)),
      subtitle: const Text('Voir les sous-etapes', style: TextStyle(color: AppColors.neutralGray)),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Column(
            children: [
              card,
              ...step.subSteps.map((sub) => StepCard(step: sub, indent: indent + 16)),
            ],
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;

  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
