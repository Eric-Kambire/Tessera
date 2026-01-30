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
                LatexView(
                  latex: step.outputLatex,
                  textStyle: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.expand_more, size: 18, color: AppColors.neutralGray),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        step.description,
                        style: const TextStyle(color: AppColors.neutralGray),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (step.subSteps.isEmpty) {
      return Column(
        children: [
          card,
          const Divider(height: 1, indent: 16, endIndent: 16),
        ],
      );
    }

    return ExpansionTile(
      tilePadding: EdgeInsets.only(left: indent),
      title: LatexView(latex: step.outputLatex),
      subtitle: Text(step.description, style: const TextStyle(color: AppColors.neutralGray)),
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
