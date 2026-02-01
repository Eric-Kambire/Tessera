import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/latex_view.dart';
import '../../domain/entities/solution_step.dart';

class StepCard extends StatelessWidget {
  final SolutionStep step;
  final double indent;
  final bool isActive;
  final String? indexLabel;
  final bool forceExpanded;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const StepCard({
    super.key,
    required this.step,
    this.indent = 0,
    this.isActive = false,
    this.indexLabel,
    this.forceExpanded = false,
    this.onPrev,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final card = Padding(
      padding: EdgeInsets.only(left: indent),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFF4F8FF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? AppColors.primaryBlue : AppColors.primaryBlue.withOpacity(0.08),
            width: isActive ? 1.2 : 1,
          ),
          boxShadow: [
            if (isActive)
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.18),
                blurRadius: 18,
                spreadRadius: 1,
              ),
            BoxShadow(
              color: Colors.black.withOpacity(isActive ? 0.08 : 0.04),
              blurRadius: isActive ? 10 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primaryBlue : AppColors.neutralGray.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      indexLabel ?? '',
                      style: TextStyle(
                        color: isActive ? Colors.white : AppColors.blackText,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: LatexView(
                      latex: step.outputLatex,
                      textStyle: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (isActive)
                    Row(
                      children: [
                        IconButton(
                          onPressed: onPrev,
                          icon: const Icon(Icons.chevron_left),
                          visualDensity: VisualDensity.compact,
                        ),
                        IconButton(
                          onPressed: onNext,
                          icon: const Icon(Icons.chevron_right),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                step.description,
                style: const TextStyle(color: AppColors.neutralGray),
              ),
            ],
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
      key: ValueKey('${step.description}-$forceExpanded'),
      initiallyExpanded: forceExpanded,
      tilePadding: EdgeInsets.only(left: indent),
      title: Text(
        step.description,
        style: TextStyle(
          color: AppColors.blackText,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
      subtitle: LatexView(latex: step.outputLatex),
      childrenPadding: const EdgeInsets.only(left: 12, right: 8, bottom: 8),
      children: [
        card,
        ...step.subSteps.map(
          (sub) => StepCard(
            step: sub,
            indent: indent + 12,
            isActive: false,
          ),
        ),
      ],
    );
  }
}
